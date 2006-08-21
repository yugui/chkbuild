require 'fileutils'
require 'time'
require 'zlib'
require "erb"
include ERB::Util
require "uri"
require "tempfile"
require "pathname"

require 'escape'
require 'timeoutcom'
require 'gdb'
require "udiff"
require "util"

module ChkBuild
end
require 'chkbuild/options'
require 'chkbuild/target'
require 'chkbuild/title'
require "chkbuild/logfile"
require 'chkbuild/upload'

class ChkBuild::Build
  include Util

  def initialize(target, suffixes, depbuilds)
    @target = target
    @suffixes = suffixes
    @depbuilds = depbuilds

    @target_dir = ChkBuild.build_top + self.depsuffixed_name
    @public = ChkBuild.public_top + self.depsuffixed_name
    @public_log = @public+"log"
    @current_txt = @public+"current.txt"
  end
  attr_reader :target, :suffixes, :depbuilds
  attr_reader :target_dir

  def suffixed_name
    name = @target.target_name.dup
    @suffixes.each {|suffix|
      name << '-' << suffix
    }
    name
  end

  def depsuffixed_name
    name = self.suffixed_name
    @depbuilds.each {|depbuild|
      name << '_' << depbuild.suffixed_name
    }
    name
  end

  def traverse_depbuild(&block)
    @depbuilds.each {|depbuild|
      yield depbuild
      depbuild.traverse_depbuild(&block)
    }
  end

  def build_time_sequence
    dirs = @target_dir.entries.map {|e| e.to_s }
    dirs.reject! {|d| /\A\d{8}T\d{6}\z/ !~ d } # year 10000 problem
    dirs.sort!
    dirs
  end

  def log_time_sequence
    names = @public_log.entries.map {|e| e.to_s }
    result = []
    names.each {|n|
      result << $1 if /\A(\d{8}T\d{6})\.txt\.gz\z/ =~ n
    }
    result.sort!
    result
  end

  ################

  def build
    dep_dirs = []
    @depbuilds.each {|depbuild|
      dep_dirs << "#{depbuild.target.target_name}=#{depbuild.dir}"
    }
    status = self.build_in_child(dep_dirs)
    status.to_i == 0
  end

  def build_in_child(dep_dirs)
    if defined? @built_status
      raise "already built"
    end
    branch_info = @suffixes + dep_dirs
    start_time_obj = Time.now
    @start_time = start_time_obj.strftime("%Y%m%dT%H%M%S")
    dir = ChkBuild.build_top + self.depsuffixed_name + @start_time
    r, w = IO.pipe
    r.close_on_exec = true
    w.close_on_exec = true
    pid = fork {
      r.close
      err = child_build_wrapper(w, *branch_info)
      if err
        exit 1
      else
        exit 0
      end
    }
    w.close
    str = r.read
    r.close
    Process.wait(pid)
    status = $?
    begin
      version = Marshal.load(str)
    rescue ArgumentError
      version = self.suffixed_name
    end
    @built_status = status
    @built_dir = dir
    @built_version = version
    return status
  end

  def start_time
    return @start_time if defined? @start_time
    raise "#{self.suffixed_name}: no start_time yet"
  end

  def success?
    if defined? @built_status
      if @built_status.to_i == 0
        true
      else
        false
      end
    else
      nil
    end
  end

  def status
    return @built_status if defined? @built_status
    raise "#{self.suffixed_name}: no status yet"
  end

  def dir
    return @built_dir if defined? @built_dir
    raise "#{self.suffixed_name}: no dir yet"
  end

  def version
    return @built_version if defined? @built_version
    raise "#{self.suffixed_name}: no version yet"
  end

  def child_build_wrapper(parent_pipe, *branch_info)
    ChkBuild.lock_puts self.depsuffixed_name
    @parent_pipe = parent_pipe
    child_build_target(*branch_info)
  end

  def child_build_target(*branch_info)
    opts = @target.opts
    @build_dir = @target_dir + @start_time
    @log_filename = @build_dir + 'log'
    mkcd @target_dir
    raise "already exist: #{@start_time}" if File.exist? @start_time
    Dir.mkdir @start_time # fail if it is already exists.
    Dir.chdir @start_time

    @logfile = ChkBuild::LogFile.write_open(@log_filename, self)
    @logfile.change_default_output
    @public.mkpath
    @public_log.mkpath
    force_link "log", @current_txt
    remove_old_build(@start_time, opts.fetch(:old, ChkBuild.num_oldbuilds))
    @logfile.start_section 'start'
    err = catch_error { @target.build_proc.call(self, *branch_info) }
    output_status_section(err)
    @logfile.start_section 'end'
    GDB.check_core(@build_dir)
    force_link @current_txt, @public+'last.txt' if @current_txt.file?
    titlegen = ChkBuild::Title.new(@target, @logfile)
    title_err = catch_error('run_title_hooks') { titlegen.run_title_hooks }
    title = titlegen.make_title
    title << " (run_title_hooks error)" if title_err
    Marshal.dump(titlegen.version, @parent_pipe)
    @parent_pipe.close
    compress_file(@log_filename, @public_log+"#{@start_time}.txt.gz")
    has_diff = make_diff
    update_summary(@start_time, title, has_diff)
    make_html_log(@log_filename, title, @public+"last.html")
    compress_file(@public+"last.html", @public+"last.html.gz")
    ChkBuild.run_upload_hooks(self.suffixed_name)
    return err
  end

  def output_status_section(err)
    if !err
      @logfile.start_section 'success'
    else
      @logfile.start_section 'failure'
      if CommandError === err
        puts "failed(#{err.reason})"
      else
        puts "failed(#{err.class}:#{err.message})"
        show_backtrace err
      end
    end
  end

  def catch_error(name=nil)
    err = nil
    begin
      yield
    rescue Exception => err
    end
    if err && name
      output_error_section("#{name} error", err)
    end
    return err
  end

  def output_error_section(secname, err)
    @logfile.start_section secname
    puts "#{err.class}:#{err.message}"
    show_backtrace err
  end

  def build_dir() @build_dir end

  def remove_old_build(current, num)
    dirs = build_time_sequence
    dirs.delete current
    return if dirs.length <= num
    dirs[-num..-1] = []
    dirs.each {|d|
      (@target_dir+d).rmtree
    }
  end

  def update_summary(start_time, title, has_diff)
    open(@public+"summary.txt", "a") {|f| f.puts "#{start_time} #{title}" }
    open(@public+"summary.html", "a") {|f|
      if f.stat.size == 0
        f.puts "<title>#{h self.depsuffixed_name} build summary</title>"
        f.puts "<h1>#{h self.depsuffixed_name} build summary</h1>"
        f.puts "<p><a href=\"../\">chkbuild</a></p>"
      end
      f.print "<a href=\"log/#{start_time}.txt.gz\" name=\"#{start_time}\">#{h start_time}</a> #{h title}"
      f.print " (<a href=\"log/#{start_time}.diff.txt.gz\">diff</a>)" if has_diff
      f.puts "<br>"
    }
  end

  def markup(str)
    result = ''
    i = 0
    str.scan(/#{URI.regexp(['http'])}/o) {
      result << h(str[i...$~.begin(0)]) if i < $~.begin(0)
      result << "<a href=\"#{h $&}\">#{h $&}</a>"
      i = $~.end(0)
    }
    result << h(str[i...str.length]) if i < str.length
    result
  end

  HTMLTemplate = <<'End'
<html>
  <head>
    <title><%= h title %></title>
    <meta name="author" content="chkbuild">
    <meta name="generator" content="chkbuild">
  </head>
  <body>
    <h1><%= h title %></h1>
    <p><a href="../">chkbuild</a> <a href="summary.html">summary</a></p>
    <pre><%= markup log %></pre>
    <hr>
    <p><a href="../">chkbuild</a> <a href="summary.html">summary</a></p>
  </body>
</html>
End

  def make_html_log(log_filename, title, dst)
    log = File.read(log_filename)
    content = ERB.new(HTMLTemplate).result(binding)
    atomic_make_file(dst, content)
  end

  def compress_file(src, dst)
    Zlib::GzipWriter.wrap(open(dst, "w")) {|z|
      open(src) {|f|
        FileUtils.copy_stream(f, z)
      }
    }
  end

  def show_backtrace(err=$!)
    puts "|#{err.message} (#{err.class})"
    err.backtrace.each {|pos| puts "| #{pos}" }
  end

  def open_gziped_log(time, &block)
    Zlib::GzipReader.wrap(open(@public_log+"#{time}.txt.gz"), &block)
  end

  def make_diff_content(time)
    times = [time]
    uncompressed = Tempfile.open("#{time}.u.")
    open_gziped_log(time) {|z|
      FileUtils.copy_stream(z, uncompressed)
    }
    uncompressed.flush
    logfile = ChkBuild::LogFile.read_open(uncompressed.path)
    logfile.dependencies.each {|dep_suffixed_name, dep_time, dep_version|
      times << dep_time
    }
    pat = Regexp.union(*times.uniq)
    tmp = Tempfile.open("#{time}.d.")
    Zlib::GzipReader.wrap(open(@public_log+"#{time}.txt.gz")) {|z|
      z.each_line {|line|
        line = line.gsub(pat, '<buildtime>')
        @target.each_diff_preprocess_hook {|block|
          catch_error(block.to_s) { line = block.call(line) }
        }
        tmp << line
      }
    }
    tmp.flush
    tmp
  end

  def make_diff
    time2 = @start_time
    entries = Dir.entries(@public_log)
    time_seq = []
    entries.each {|f|
      if /\A(\d{8}T\d{6})\.txt\.gz\z/ =~ f # year 10000 problem
        time_seq << $1
      end
    }
    time_seq.sort!
    time_seq.delete time2
    return false if time_seq.empty?
    time1 = time_seq.last
    has_diff = false
    output_path = @public_log+"#{time2}.diff.txt.gz"
    Zlib::GzipWriter.wrap(open(output_path, "w")) {|z|
      has_diff = output_diff(time1, time2, z)
    }
    if !has_diff
      output_path.unlink
      return false
    end
    return true
  end

  def output_diff(t1, t2, out)
    has_diff = false
    open_gziped_log(t2) {|f|
      has_change_line = false
      f.each {|line|
        if ChkBuild::Target::CHANGE_LINE_PAT =~ line
          out.puts line
          has_change_line = true
        end
      }
      if has_change_line
        out.puts
        has_diff = true
      end
    }
    tmp1 = make_diff_content(t1)
    tmp2 = make_diff_content(t2)
    header = "--- #{t1}\n+++ #{t2}\n"
    has_diff |= UDiff.diff(tmp1.path, tmp2.path, out, header)
    has_diff
  end

  class CommandError < StandardError
    def initialize(status, reason, message=reason)
      super message
      @reason = reason
      @status = status
    end

    attr_accessor :reason
  end
  def run(command, *args, &block)
    opts = @target.opts.dup
    opts.update args.pop if Hash === args.last

    if opts.include?(:section)
      secname = opts[:section]
    else
      secname = opts[:reason] || File.basename(command)
    end
    @logfile.start_section(secname) if secname

    puts "+ #{[command, *args].map {|s| Escape.shell_escape s }.join(' ')}"
    pos = STDOUT.pos
    TimeoutCommand.timeout_command(opts.fetch(:timeout, '1h')) {
      opts.each {|k, v|
        next if /\AENV:/ !~ k.to_s
        ENV[$'] = v
      }
      if Process.respond_to? :setrlimit
        resource_unlimit(:RLIMIT_CORE)
	limit = ChkBuild.get_limit
	opts.each {|k, v| limit[$'.intern] = v if /\Ar?limit_/ =~ k.to_s }
        resource_limit(:RLIMIT_CPU, limit.fetch(:cpu))
        resource_limit(:RLIMIT_STACK, limit.fetch(:stack))
        resource_limit(:RLIMIT_DATA, limit.fetch(:data))
        resource_limit(:RLIMIT_AS, limit.fetch(:as))
	#system('sh', '-c', "ulimit -a")
      end
      alt_commands = opts.fetch(:alt_commands, [])
      begin
        exec command, *args
      rescue Errno::ENOENT
        if !alt_commands.empty?
          command = alt_commands.shift
          retry
        else
          raise
        end
      end
    }
    begin
      if $?.exitstatus != 0
        if $?.exited?
          puts "exit #{$?.exitstatus}"
        elsif $?.signaled?
          puts "signal #{SignalNum2Name[$?.termsig]} (#{$?.termsig})"
        elsif $?.stopped?
          puts "stop #{SignalNum2Name[$?.stopsig]} (#{$?.stopsig})"
        else
          p $?
        end
        raise CommandError.new($?, opts.fetch(:section, command))
      end
    end
  end

  SignalNum2Name = Signal.list.invert
  SignalNum2Name.default = 'unknown signal'

  def make(*targets)
    opts = {}
    opts = targets.pop if Hash === targets.last
    opts = opts.dup
    opts[:alt_commands] = ['make']
    if targets.empty?
      opts[:section] ||= 'make'
      self.run("gmake", opts)
    else
      targets.each {|target|
        h = opts.dup
        h[:reason] = target
        h[:section] = target
        self.run("gmake", target, h)
      }
    end
  end
end

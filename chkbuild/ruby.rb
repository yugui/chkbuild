require 'build'

def def_build_ruby(*args)
  opts = Hash === args.last ? args.pop : {}
  default_opts = {:separated_srcdir=>false}
  opts = default_opts.merge(opts)
  args.push opts
  def_build_ruby_internal(*args)
end

def def_build_ruby2(*args)
  opts = Hash === args.last ? args.pop : {}
  default_opts = {:separated_srcdir=>true}
  opts = default_opts.merge(opts)
  args.push opts
  def_build_ruby_internal(*args)
end

def def_build_ruby_internal(*args)
  opts = Hash === args.last ? args.last : {}
  separated_srcdir = opts[:separated_srcdir]
  t = Build.def_target("ruby", *args) {|b, *suffixes|
    ruby_work_dir = b.work_dir

    ruby_branch = nil
    configure_flags = []
    cflags = %w{-Wall -Wformat=2 -Wno-parentheses -g -O2 -DRUBY_GC_STRESS}
    gcc_dir = nil
    autoconf_command = 'autoconf'
    make_options = {}
    suffixes.each {|s|
      case s
      when "trunk" then ruby_branch = nil
      when "1.8" then ruby_branch = 'ruby_1_8'
      when "yarv" then ruby_branch = 'yarv'
      when "o0"
        cflags.delete_if {|arg| /\A-O\d\z/ =~ arg }
        cflags << '-O0'
      when "o1"
        cflags.delete_if {|arg| /\A-O\d\z/ =~ arg }
        cflags << '-O1'
      when "o3"
        cflags.delete_if {|arg| /\A-O\d\z/ =~ arg }
        cflags << '-O3'
      when "pth" then configure_flags << '--enable-pthread'
      when /\Agcc=/
        configure_flags << "CC=#{$'}/bin/gcc"
        make_options["ENV:LD_RUN_PATH"] = "#{$'}/lib"
      when /\Aautoconf=/
        autoconf_command = "#{$'}/bin/autoconf"
      else
        raise "unexpected suffix: #{s.inspect}"
      end
    }

    objdir = ruby_work_dir+'ruby'
    if separated_srcdir
      checkout_dir = ruby_work_dir.dirname
    else
      checkout_dir = ruby_work_dir
    end
    srcdir = (checkout_dir+'ruby').relative_path_from(objdir)

    Dir.chdir(checkout_dir)
    if ruby_branch == 'yarv'
      b.svn("http://www.atdot.net/svn/yarv", "trunk", 'ruby',
        :viewcvs=>'http://www.atdot.net/viewcvs/yarv')
    else
      b.cvs(
        ":pserver:anonymous@cvs.ruby-lang.org:/src", "ruby", ruby_branch,
        :cvsweb => "http://www.ruby-lang.org/cgi-bin/cvsweb.cgi")
    end
    Dir.chdir("ruby")
    b.run(autoconf_command)

    Dir.chdir(ruby_work_dir)
    b.mkcd("ruby")
    b.run("#{srcdir}/configure", "--prefix=#{ruby_work_dir}", "CFLAGS=#{cflags.join(' ')}", *configure_flags)
    b.make(make_options)
    b.run("./ruby", "-v", :section=>"version")
    b.make("install")
    b.run("./ruby", "#{srcdir+'sample/test.rb'}", :section=>"test.rb")
    b.run("./ruby", "#{srcdir+'test/runner.rb'}", "-v", :section=>"test-all")
  }

  t.add_title_hook("configure") {|title, log|
    if /^checking target system type\.\.\. (\S+)$/ =~ log
      title.update_title(:version, "#{title.suffixed_name} [#{$1}]")
    end
  }

  t.add_title_hook("version") {|title, log|
    if /^ruby [0-9.]+ \([0-9\-]+\) \[\S+\]$/ =~ log
      ver = $&
      ss = title.suffixed_name.split(/-/)[1..-1].reject {|s| /\A(pth|o\d)\z/ !~ s }
      ver << " [#{ss.join(',')}]" if !ss.empty?
      title.update_title(:version, ver)
    end
  }
    
  t.add_title_hook("test.rb") {|title, log|
    title.update_title(:status) {|val|
      if /^end of test/ !~ log
        if /^test: \d+ failed (\d+)/ =~ log
          "#{$1}NotOK"
        end
      end
    }
  }

  t.add_title_hook("test-all") {|title, log|
    title.update_title(:status) {|val|
      if /^\d+ tests, \d+ assertions, (\d+) failures, (\d+) errors$/ =~ log
        failures = $1.to_i
        errors = $2.to_i
        if failures != 0 || errors != 0
          "#{failures}F#{errors}E"
        end
      end
    }
  }

  t.add_title_hook(nil) {|title, log|
    mark = ''
    mark << "[BUG]" if /\[BUG\]/i =~ log
    mark << "[SEGV]" if /segmentation fault|signal segv/i =~
      log.sub(/combination may cause frequent hang or segmentation fault/, '') # skip tk message.
    mark << "[FATAL]" if /\[FATAL\]/i =~ log
    title.update_title(:mark, mark)
  }

  t.add_diff_preprocess_gsub(/^ *\d+\) (Error:|Failure:)/) {|match|
    " <n>) #{match[1]}"
  }

  t.add_diff_preprocess_gsub(%r{\(druby://localhost:\d+\)}) {|match|
    "(druby://localhost:<port>)"
  }

  t.add_diff_preprocess_gsub(/^Elapsed: [0-9.]+s/) {|match|
    "Elapsed: <t>s"
  }

  t.add_diff_preprocess_gsub(/^Finished in [0-9.]+ seconds\./) {|match|
    "Finished in <t> seconds."
  }

  t
end

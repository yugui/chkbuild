# chkbuild/logfile.rb - chkbuild's log file library
#
# Copyright (C) 2006,2009 Tanaka Akira  <akr@fsij.org>
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  3. The name of the author may not be used to endorse or promote products
#     derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.

require 'time'

class IO
  def tmp_reopen(io)
    save = self.dup
    begin
      self.reopen(io)
      begin
        yield
      ensure
        self.reopen(save)
      end
    ensure
      save.close
    end
  end
end

module ChkBuild
end

class ChkBuild::LogFile
  InitialMark = '=='

  def self.os_version
    if File.readable?("/etc/debian_version")
      ver = File.read("/etc/debian_version").chomp
      case ver
      when /\A2\.0/; codename = 'potato'
      when /\A3\.0/; codename = 'woody'
      when /\A3\.1/; codename = 'sarge'
      when /\A4\.0/; codename = 'etch'
      when /\A5\.0/; codename = 'lenny'
      else codename = nil
      end
      ver = "Debian GNU/Linux #{ver}"
      ver << " (#{codename})" if codename
      return ver
    end
    nil
  end

  def self.show_os_version
    system("uname -a")
    system("sw_vers") # MacOS X
    if !system("lsb_release -idrc") # recent GNU/Linux
      os_ver = self.os_version
      puts os_ver if os_ver
    end
  end

  def self.write_open(filename, build)
    logfile = self.new(filename, true)
    logfile.start_section build.depsuffixed_name
    logfile.with_default_output {
      self.show_os_version
      section_started = false
      build.traverse_depbuild {|depbuild|
        if !section_started
          logfile.start_section 'dependencies'
          section_started = true
        end
        if depbuild.suffixed_name == depbuild.version
          puts "#{depbuild.suffixed_name} #{depbuild.start_time}"
        else
          puts "#{depbuild.suffixed_name} #{depbuild.start_time} (#{depbuild.version})"
        end
      }
    }
    logfile
  end

  def dependencies
    return [] unless log = self.get_section('dependencies')
    r = []
    log.each_line {|line|
      if /^(\S+) (\d+T\d+) \((.*)\)$/ =~ line
        r << [$1, $2, $3]
      elsif /^(\S+) (\d+T\d+)$/ =~ line
        r << [$1, $2, $1]
      end
    }
    r
  end

  def depsuffixed_name
    return @depsuffixed_name if defined? @depsuffixed_name
    if /\A\S+\s+(\S+)/ =~ self.get_all_log
      return @depsuffixed_name = $1
    end
    raise "unexpected log format"
  end

  def suffixed_name() depsuffixed_name.sub(/_.*/, '') end
  def target_name() suffixed_name.sub(/-.*/, '') end
  def suffixes() suffixed_name.split(/-/)[1..-1] end

  def self.read_open(filename)
    self.new(filename, false)
  end

  def initialize(filename, writemode)
    @writemode = writemode
    mode = writemode ? File::RDWR|File::CREAT|File::APPEND : File::RDONLY
    @filename = filename
    @io = File.open(filename, mode)
    @io.set_encoding("ascii-8bit") if @io.respond_to? :set_encoding
    @io.sync = true
    @mark = read_separator
    @sections = detect_sections
  end

  def read_separator
    mark = nil
    if @io.stat.size != 0
      @io.rewind
      mark = @io.gets[/\A\S+/]
    end
    mark || InitialMark
  end
  private :read_separator

  def detect_sections
    ret = {}
    @io.rewind
    pat = /\A#{Regexp.quote @mark} /
    @io.each {|line|
      if pat =~ line
        epos = @io.pos
        spos = epos - line.length
        secname = $'.chomp.sub(/#.*/, '').strip
        ret[secname] = spos
      end
    }
    ret
  end
  private :detect_sections

  # logfile.with_default_output { ... }
  def with_default_output
    raise "not opened for writing" if !@writemode
    File.open(@filename, File::WRONLY|File::APPEND) {|f|
      STDERR.tmp_reopen(f) {
        STDERR.sync = true
        STDOUT.tmp_reopen(f) {
          STDOUT.sync = true
          yield
        }
      }
    }
  end

  def change_default_output
    raise "not opened for writing" if !@writemode
    STDOUT.reopen(@save_io = File.for_fd(@io.fileno, File::WRONLY|File::APPEND))
    STDERR.reopen(STDOUT)
    STDOUT.sync = true
    STDERR.sync = true
  end

  # start_section returns the (unique) section name.
  def start_section(secname)
    @io.flush
    if 0 < @io.stat.size
      @io.seek(-1, IO::SEEK_END)
      if @io.read != "\n"
        @io.write "\n"
      end
    end
    spos = @io.pos
    secname = secname.strip
    if @sections[secname]
      i = 2
      while @sections["#{secname}(#{i})"]
        i += 1
      end
      secname = "#{secname}(#{i})"
    end
    @sections[secname] = spos
    @io.write "#{@mark} #{secname} \# #{Time.now.iso8601}\n"
    secname
  end

  def secnames
    @sections.keys.sort_by {|secname| @sections[secname] }
  end

  def each_secname(&block)
    @sections.keys.sort_by {|secname| @sections[secname] }.each(&block)
  end

  def section_size(secname)
    spos = @sections[secname]
    raise ArgumentError, "no section : #{secname.inspect}" if !spos
    epos = @sections.values.reject {|pos| pos <= spos }.min
    epos = @io.stat.size if !epos
    epos - spos
  end

  def get_section(secname)
    spos = @sections[secname]
    return nil if !spos
    @io.seek spos
    @io.gets("\n#{@mark} ").chomp("#{@mark} ").sub(/\A.*\n/, '')
  end

  def get_all_log
    @io.rewind
    @io.read
  end

  def modify_section(secname, data)
    raise "not opened for writing" if !@writemode
    spos = @sections[secname]
    raise ArgumentError, "no section: #{secname.inspect}" if !spos
    data += "\n" if /\n\z/ !~ data
    old = nil
    File.open(@filename, File::RDWR) {|f|
      f.seek spos
      rest = f.read
      if /\n#{Regexp.quote @mark} / =~ rest
        epos = $~.begin(0) + 1
        curr = rest[0...epos]
        rest = rest[epos..-1]
      else
        curr = rest
        rest = ''
      end
      if /\n/ =~ curr
        secline = $` + $&
        old = $'
      else
        secline = curr + "\n"
        old = ''
      end
      f.seek spos
      f.print secline, data, rest
      f.flush
      f.truncate(f.pos)
    }
    off = data.length - old.length
    @sections.each_pair {|n, pos|
      if spos < pos
        @sections[n] = pos + off
      end
    }
    nil
  end
end

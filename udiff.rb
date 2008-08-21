require 'escape'
require 'tempfile'

class UDiff
  def UDiff.diff(path1, path2, out, header="--- #{path1}\n+++ #{path2}\n")
    UDiff.new(path1, path2, out, header).diff
  end

  def initialize(path1, path2, out, header)
    @path1 = path1
    @path2 = path2
    @out = out
    @header = header
    @context = 3
    @beginning = true
    @l1 = 0
    @l2 = 0
    @hunk_beg = [@l1, @l2]
    @hunk = []
    @lines_hash = {}
    @lines_ary = []
  end

  def puts_line(line)
    @hunk << line
    if /\n\z/ !~ line
      @hunk << "\n\\ No newline at end of file\n"
    end
    @beginning = false
  end

  def puts_del_line(line)
    puts_line "-#{@lines_ary[line.to_i]}"
  end

  def puts_add_line(line)
    puts_line "+#{@lines_ary[line.to_i]}"
  end

  def puts_common_line(line)
    puts_line " #{@lines_ary[line.to_i]}"
  end

  def encdump(str)
    d = str.dump
    if str.respond_to? :encoding
      "#{d}.force_encoding(#{str.encoding.name.dump})"
    else
      d
    end
  end

  def gets_common_line(f1, f2)
    v1 = f1.gets
    v2 = f2.gets
    if v1 != v2
      raise "[bug] diff error: #{encdump v1} != #{encdump v2}"
    end
    if v1
      @l1 += 1
      @l2 += 1
    end
    return v1
  end

  def copy_common_part(f1, f2, n)
    n.times {|i|
      v = gets_common_line(f1, f2)
      raise "[bug] diff error: unexpected EOF" unless v
      puts_common_line(v)
    }
  end

  def skip_common_part(f1, f2, n)
    n.times {|i|
      v = gets_common_line(f1, f2)
      raise "[bug] diff error: unexpected EOF" unless v
    }
  end

  def output_hunk
    if @header
      @out.print @header
      @header = nil
    end
    l1_beg, l2_beg = @hunk_beg
    @out.print "@@ -#{l1_beg+1},#{@l1-l1_beg} +#{l2_beg+1},#{@l2-l2_beg} @@\n"
    @hunk.each {|s|
      @out.print s
    }
  end

  def output_common_part(f1, f2, common_num)
    if @beginning
      if common_num <= @context
        copy_common_part(f1, f2, common_num)
      else
        skip_common_part(f1, f2, common_num-@context)
        copy_common_part(f1, f2, @context)
      end
    elsif common_num <= @context * 2
      copy_common_part(f1, f2, common_num)
    else
      copy_common_part(f1, f2, @context)
      output_hunk
      skip_common_part(f1, f2, common_num-@context*2)
      @hunk_beg = [@l1, @l2]
      @hunk = []
      copy_common_part(f1, f2, @context)
    end
  end

  def output_common_tail(f1, f2)
    return if @beginning
    @context.times {
      v = gets_common_line(f1, f2)
      break unless v
      puts_common_line(v)
    }
    output_hunk
  end

  def process_commands(f1, f2, d)
    has_diff = false
    l1 = 0
    while com = d.gets
      case com
      when /\Ad(\d+) (\d+)/
        line = $1.to_i
        num = $2.to_i
        output_common_part(f1, f2, line-l1-1)
        num.times {
          v = f1.gets
          @l1 += 1
          puts_del_line(v)
          has_diff = true
        }
        l1 = line + num - 1
      when /\Aa(\d+) (\d+)/
        line = $1.to_i
        num = $2.to_i
        common_num = line-l1
        output_common_part(f1, f2, line-l1)
        l1 = line
        num.times {
          v1 = d.gets
          v2 = f2.gets
          if v1 != v2
            raise "[bug] diff error: #{encdump v1} != #{encdump v2}"
          end
          @l2 += 1
          v = v1
          puts_add_line(v)
          has_diff = true
        }
      else
        raise "[bug] unexpected diff line: #{com.inspect}"
      end
    end
    has_diff
  end

  def run_diff(path1, path2)
    has_diff = false
    open(path1) {|f1|
      f1.set_encoding "ascii-8bit" if f1.respond_to? :set_encoding
      open(path2) {|f2|
        f2.set_encoding "ascii-8bit" if f2.respond_to? :set_encoding
        command = Escape.shell_command(%W[diff -n #{path1} #{path2}]).to_s
	command = "LC_ALL='C' LANG='C' #{command}"
        IO.popen(command) {|d|
          d.set_encoding "ascii-8bit" if d.respond_to? :set_encoding
          has_diff = process_commands(f1, f2, d)
        }
        output_common_tail(f1, f2)
      }
    }
    has_diff
  end

  def diff
    t1 = Tempfile.new("udiff")
    File.foreach(@path1) {|l|
      if !@lines_hash[l]
	@lines_ary[@lines_hash.size] = l
	@lines_hash[l] = @lines_hash.size 
      end
      t1.puts @lines_hash[l]
    }
    t2 = Tempfile.new("udiff")
    File.foreach(@path2) {|l|
      if !@lines_hash[l]
	@lines_ary[@lines_hash.size] = l
	@lines_hash[l] = @lines_hash.size 
      end
      t2.puts @lines_hash[l]
    }
    t1.close
    t2.close
    run_diff(t1.path, t2.path)
  end
end

if $0 == __FILE__
  UDiff.diff(ARGV[0], ARGV[1], STDOUT)
end

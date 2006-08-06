require 'fileutils'

class ChkBuild::Build
  def svn(url, working_dir, opts={})
    opts = opts.dup
    opts[:section] ||= 'svn'
    if File.exist?(working_dir) && File.exist?("#{working_dir}/.svn")
      Dir.chdir(working_dir) {
        self.run "svn", "cleanup", opts
        opts[:section] = nil
        h1 = svn_revisions
        self.run "svn", "update", opts
        h2 = svn_revisions
      }
    else
      if File.exist?(working_dir)
        FileUtils.rm_rf(working_dir)
      end
      self.run "svn", "checkout", "-q", url, working_dir, opts
    end
  end

  def svn_revisions
    h = {}
    IO.popen("svn status -v") {|f|
      f.each {|line|
        if /\d+\s+(\d+)\s+\S+\s+(\S+)/ =~ line
          rev = $1.to_i
          path = $2
          h[path] = rev
        end
      }
    }
    h
  end

  def svn_print_revisions(h1, h2, viewcvs=nil)
    changes = 'changes:'
    (h1.keys|h2.keys).each {|f|
      r1 = h1[f] || 'none'
      r2 = h2[f] || 'none'
      next if r1 == r2
      if changes
        puts changes
        changes = nil
      end
      line = "#{f}\t#{r1} -> #{r2}"
      puts line
    }
  end
end

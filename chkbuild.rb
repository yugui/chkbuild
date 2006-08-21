require 'chkbuild/main'
require 'chkbuild/lock'
require 'chkbuild/cvs'
require 'chkbuild/svn'
require 'chkbuild/xforge'
require "util"
require 'chkbuild/target'
require 'chkbuild/build'

module ChkBuild
  autoload :Ruby, 'chkbuild/ruby'
  autoload :GCC, 'chkbuild/gcc'
end

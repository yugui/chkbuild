# Copyright (C) 2006,2008,2009 Tanaka Akira  <akr@fsij.org>
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

Encoding.default_external = "ASCII-8BIT" if defined?(Encoding.default_external = nil)

Dir.glob( File.join(File.expand_path("../../core_ext", __FILE__), '*.rb') ) do |path|
  require path
end
$: << File.expand_path("../misc", __FILE__)

require 'chkbuild/main'
require 'chkbuild/lock'
require 'chkbuild/scm/cvs'
require 'chkbuild/scm/svn'
require 'chkbuild/scm/git'
require 'chkbuild/scm/xforge'
require "util"
require 'chkbuild/target'
require 'chkbuild/build'

module ChkBuild
  autoload :Ruby, 'chkbuild/targets/ruby'
  autoload :GCC, 'chkbuild/targets/gcc'
end

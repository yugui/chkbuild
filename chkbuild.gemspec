# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{chkbuild}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["TANAKA, Akira", "Yuki Sonoda (Yugui)"]
  s.date = %q{2009-09-27}
  s.email = %q{yugui@yugui.jp}
  s.executables = ["last-build", "start-build"]
  s.extra_rdoc_files = [
    "README.ja.rd"
  ]
  s.files = [
    "README.ja.rd",
     "Rakefile",
     "VERSION",
     "bin/last-build",
     "bin/start-build",
     "lib/chkbuild.rb",
     "lib/chkbuild/build.rb",
     "lib/chkbuild/cvs.rb",
     "lib/chkbuild/gcc.rb",
     "lib/chkbuild/git.rb",
     "lib/chkbuild/lock.rb",
     "lib/chkbuild/logfile.rb",
     "lib/chkbuild/main.rb",
     "lib/chkbuild/options.rb",
     "lib/chkbuild/ruby.rb",
     "lib/chkbuild/svn.rb",
     "lib/chkbuild/target.rb",
     "lib/chkbuild/title.rb",
     "lib/chkbuild/upload.rb",
     "lib/chkbuild/xforge.rb",
     "lib/misc/escape.rb",
     "lib/misc/gdb.rb",
     "lib/misc/timeoutcom.rb",
     "lib/misc/udiff.rb",
     "lib/misc/util.rb",
     "sample/build-autoconf-ruby",
     "sample/build-gcc-ruby",
     "sample/build-ruby",
     "sample/build-ruby2",
     "sample/build-svn",
     "sample/build-yarv",
     "sample/test-apr",
     "sample/test-catcherr",
     "sample/test-combfail",
     "sample/test-core",
     "sample/test-core2",
     "sample/test-date",
     "sample/test-dep",
     "sample/test-depver",
     "sample/test-echo",
     "sample/test-env",
     "sample/test-error",
     "sample/test-fail",
     "sample/test-fmesg",
     "sample/test-gcc-v",
     "sample/test-git",
     "sample/test-leave-proc",
     "sample/test-limit",
     "sample/test-make",
     "sample/test-neterr",
     "sample/test-savannah",
     "sample/test-sleep",
     "sample/test-timeout",
     "sample/test-timeout2",
     "sample/test-timeout3",
     "sample/test-upload",
     "sample/test-warn",
     "setup/upload-rsync-ssh",
     "test/misc/test-escape.rb",
     "test/misc/test-logfile.rb",
     "test/misc/test-timeoutcom.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/yugui/chkbuild}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{gemified version of akr's chkbuild - a robust continuous building system}
  s.test_files = [
    "test/misc/test-escape.rb",
     "test/misc/test-logfile.rb",
     "test/misc/test-timeoutcom.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

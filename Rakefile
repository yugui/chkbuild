require 'rubygems'
require 'rake'
require 'rdoc/task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "chkbuild"
    gem.summary = %Q{gemified version of akr's chkbuild - a robust continuous building system}
    gem.email = "yugui@yugui.jp"
    gem.homepage = "http://github.com/yugui/chkbuild"
    gem.authors = ["TANAKA, Akira", "Yuki Yugui Sonoda"]
    gem.files = %w[ bin core_ext lib setup sample test].inject([]){|set, dir| set + Dir["#{dir}/**/*"]} +
      %w[ README.ja.rd Rakefile VERSION lchg.rb erbio.rb ]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/misc/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :test

Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "chkbuild #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


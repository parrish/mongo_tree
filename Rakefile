require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mongo_tree"
    gem.summary = %Q{A MongoMapper plugin that adds a number of tree strategies.}
    gem.description = %Q{A MongoMapper plugin that adds a number of tree strategies.}
    gem.email = "mtparrish@gmail.com"
    gem.homepage = "http://github.com/parrish/mongo_tree"
    gem.authors = ["Michael Parrish"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency "mongo_mapper", ">= 0.8.2"
    gem.files = Dir.glob("{lib,test}/**/*") + %w[LICENSE README.markdown]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mongo_tree #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

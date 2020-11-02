begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile",__FILE__)
load 'rails/tasks/engine.rake'
Bundler::GemHelper.install_tasks
Dir[File.join(File.dirname(__FILE__), 'tasks/**/*.rake')].each {|f| load f }

#require 'rdoc/task'
require 'rspec/core'
require 'rspec/core/rake_task'

#RDoc::Task.new(:rdoc) do |rdoc|
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title    = 'Light'
#  rdoc.options << '--line-numbers'
#  rdoc.rdoc_files.include('README.rdoc')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end

desc "Run all specs in spec directory (excluding plugin specs)"

RSpec::Core::RakeTask.new(:spec => 'app:db:test:prepare')


#Bundler::GemHelper.install_tasks

#require 'rake/testtask'

#Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib'
#  t.libs << 'test'
#  t.pattern = 'test/**/*_test.rb'
#  t.verbose = false
#end


#task default: :test
task default: :spec

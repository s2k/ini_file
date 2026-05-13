# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Run the tests'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

task default: %i[test rubocop]

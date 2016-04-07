require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :spec

task :doc => 'doc/doc.pdf'

file 'doc/doc.pdf' => ['doc/doc.md', 'stats/stats.R'] do |t|
  puts "Generating tables and graphics..."
  `cd stats; ./stats.R; cd ..`
  puts "Compiling #{t.prerequisites[0]}->#{t.name} with pandoc..."
  `pandoc #{t.prerequisites[0]} -o #{t.name} --filter pandoc-eqnos --filter pandoc-citeproc --latex-engine=xelatex`
end

require 'rake/extensiontask'
spec = Gem::Specification.load('feature-selection.gemspec')
Rake::ExtensionTask.new('c_knn', spec)

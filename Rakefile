require 'rake/testtask'

Rake::TestTask.new('test') do |t|
  t.libs << "test"
  t.test_files = FileList['test/tests/**/*.rb']
end

task 'test:all' do
  Rake::Task['test'].execute

  %w(chrome poltergeist).each do |browser|
    ENV['BROWSER'] = browser
    Rake::Task['test'].execute
  end
end

task :build do
  system 'gem build wist.gemspec'
  `rm -rf build`
  `mkdir build`
  `mv *.gem build`
end
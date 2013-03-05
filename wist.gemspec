Gem::Specification.new do |gem|
  gem.name     = 'wist'
  gem.version  = '0.0.5'
  gem.summary  = 'capybara helpers'
  gem.author   = 'Lihan Li'
  gem.email    = 'frankieteardrop@gmail.com'
  gem.homepage = 'http://github.com/lihanli/wist'

  gem.add_dependency 'capybara'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end
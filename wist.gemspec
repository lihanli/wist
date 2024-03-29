Gem::Specification.new do |gem|
  gem.name     = 'wist'
  gem.version  = '0.6.0'
  gem.summary  = 'capybara helpers'
  gem.author   = 'Lihan Li'
  gem.email    = 'frankieteardrop@gmail.com'
  gem.homepage = 'http://github.com/lihanli/wist'
  gem.license  = 'MIT'

  gem.add_dependency 'capybara'
  gem.add_dependency 'selenium-webdriver'
  gem.add_dependency 'common_assert'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end

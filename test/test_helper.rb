require 'capybara'
require 'capybara/poltergeist'
require 'wist'
require 'pry'
begin; require 'turn/autorun'; rescue LoadError; end
Turn.config.format = :dot

class CapybaraTestCase < Test::Unit::TestCase
  include Capybara::DSL
  include Wist

  def setup
    Capybara.javascript_driver = :poltergeist
    Capybara.current_driver = Capybara.javascript_driver
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
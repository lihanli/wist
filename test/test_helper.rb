require 'wist'
require 'capybara/poltergeist'
require 'pry'
require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use!

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Wist

  def setup
    Capybara.javascript_driver = ENV['BROWSER'].to_sym if ENV['BROWSER']
    Capybara.current_driver    = Capybara.javascript_driver
  end

  def teardown
    Capybara.reset_sessions!
  end
end
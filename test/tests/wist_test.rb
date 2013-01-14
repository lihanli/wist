require 'test_helper'

class TestWist < CapybaraTestCase
  def setup
    super
    visit "file://#{Dir.pwd}/test/test.html"
  end

  def test_click
    click '#click_test'
    assert_equal 'clicked', find('#click_test').text
  end

  def test_wait_until
    button = find('#wait_test')
    button.click
    assert button.text != 'clicked'
    wait_until { button.text == 'clicked' }
  end

end
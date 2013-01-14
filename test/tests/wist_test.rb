require 'test_helper'

class TestWist < CapybaraTestCase
  def setup
    super
    visit "file://#{Dir.pwd}/test/test0.html"
  end

  # helpers
  def verify_test_page(num)
    assert current_path.match(/test#{num}.html$/)
  end

  # tests
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

  def test_verify_tweet_button
    click '#enable_tweet_button'
    verify_tweet_button 'check this out'
  end

  def test_switch_to_window_and_execute

    verify_test_page 0
    click '#switch_window_test'

    switch_to_window_and_execute do
      verify_test_page 1
    end

    verify_test_page 0
  end

  def test_get_js
    assert get_js('document.URL').match(/test0.html$/)
  end

  def test_get_val
    find('#input_test').set 'foo'
    assert_equal 'foo', get_val('#input_test')
  end

  def test_has_class
    %w(foo bar).each { |c| assert has_class('#class_test', c) }
    assert_equal false, has_class('#class_test', 'baz')
  end

  def test_alert_accept
    click '#alert_test'
    alert_accept 'alert'
  end

  def test_wait_for_new_url
    verify_test_page 0
    wait_for_new_url find('#wait_for_new_url_test')
    verify_test_page 1
  end

  def test_refresh
    find('#input_test').set 'foo'
    refresh
    assert_equal '', get_val('#input_test')
  end

  def test_element_displayed?
    assert_equal false, element_displayed?('#invisible')
    assert element_displayed?('#input_test')
  end

end
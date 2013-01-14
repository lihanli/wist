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

  def test_verify_tweet_button
    click '#enable_tweet_button'
    verify_tweet_button 'check this out'
  end

  def test_switch_to_window_and_execute
    assert_on_window_1 = -> { assert current_path.match(/test.html$/) }

    assert_on_window_1.()
    click '#switch_window_test'

    switch_to_window_and_execute do
      assert current_path.match(/test1.html$/)
    end

    assert_on_window_1.()
  end

  def test_get_js
    assert get_js('document.URL').match(/test.html$/)
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

end
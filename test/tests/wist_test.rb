require 'test_helper'

class WistTest < CapybaraTestCase
  def setup
    super
    visit "file://#{Dir.pwd}/test/test0.html"
  end

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
    return if Capybara.javascript_driver == :poltergeist
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
    el = find('#class_test')
    %w(foo bar).each { |c| assert_equal(true, has_class?(el, c)) }
    assert_equal(false, has_class?(el, 'baz'))
  end

  def test_alert_accept
    alert_accept 'alert' do
      click '#alert_test'
    end
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

  def test_wait_til_element_visible
    el = find('#test_wait_til_element_visible')
    el.click
    assert_equal false, el.visible?

    assert wait_til_element_visible('#test_wait_til_element_visible').visible?
  end

  def test_set_value_and_trigger_evts
    set_value_and_trigger_evts('#test_set_value_and_trigger_evts', 'foo')
    assert_equal('changed', get_val('#test_set_value_and_trigger_evts'))
  end

  def test_set_cookie
    return if Capybara.javascript_driver == :chrome
    set_cookie('foo', 'bar')
    assert_equal('bar', page.evaluate_script("$.cookie('foo')"))
  end

  def test_set_input_and_press_enter
    alert_accept('enter pressed') do
      set_input_and_press_enter('#test_set_input_and_press_enter', 'bar')
    end
    assert_equal('bar', get_val('#test_set_input_and_press_enter'))
  end
end
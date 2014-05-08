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

    wait_until do
      raise unless button.text == 'clicked'
      true
    end

    # make sure default wait time is back to normal
    assert_equal(2, Capybara.default_wait_time)
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
    el = find('#class_test', visible: false)
    %w(foo bar).each { |c| assert_equal(true, has_class?(el, c)) }
    assert_equal(false, has_class?(el, 'baz'))

    assert_equal(false, has_class?(find('#click_test'), 'foo'))
  end

  def test_alert_accept
    alert_accept 'alert' do
      click '#alert_test'
    end
  end

  def test_wait_for_new_url
    verify_test_page(0)
    wait_for_new_url(find('#wait_for_new_url_test'))
    verify_test_page(1)
  end

  def test_wait_for_new_url_with_block
    wait_for_new_url { click('#wait_for_new_url_test') }
    verify_test_page(1)
  end

  def test_refresh
    find('#input_test').set 'foo'
    refresh
    assert_equal '', get_val('#input_test')
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

  def test_scroll_to
    old_offset = get_js('window.pageYOffset')
    scroll_to('#test_scroll_to')
    assert_equal(true, get_js('window.pageYOffset') != old_offset)
  end

  def test_finder_with_wait
    click('#finder_with_wait')
    assert_equal('finder_with_wait', first_with_wait('.done', visible: true)[:id])

    refresh
    click('#finder_with_wait')
    assert_equal('finder_with_wait', all_with_wait('.done', visible: true)[0][:id])
  end

  def test_visit_with_retries
    return unless Capybara.javascript_driver == :poltergeist

    assert_raise RuntimeError do
      visit_with_retries('a.bc', retries: 2, wait_time: 1)
    end

    visit_with_retries("file://#{Dir.pwd}/test/test0.html")
    verify_test_page(0)
  end

  def test_assert_text
    assert_text('foo', find('#click_test'))
  end

  def test_assert_text_include
    assert_text_include('fo', find('#click_test'))
  end

  def test_parent
    assert_text('parent', parent(find('#test_parent', visible: false)))
  end

  def test_click_by_text
    click_by_text('button', 'click by text')
    assert_text('clicked', find('#click_by_text'))
  end

  def test_assert_css
    assert_has_css('#click_test', visible: true)
    assert_has_no_css('#dog123')
  end

  def test_has_css_instant?
    assert_equal(true, has_css_instant?('body'))
    assert_equal(false, has_css_instant?('#sdklfjk'))
  end

  def test_do_instantly
    old_time = Capybara.default_wait_time
    new_time = nil

    begin
      do_instantly do
        new_time = Capybara.default_wait_time
        raise
      end
    rescue
    end

    assert_equal(0, new_time)
    assert_equal(old_time, Capybara.default_wait_time)
  end
end
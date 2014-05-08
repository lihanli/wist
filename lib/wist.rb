module Wist
  require 'selenium-webdriver'
  require 'cgi'
  require 'capybara'

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  module Helpers
    module_function

    def blank?(obj)
      obj.respond_to?(:empty?) ? obj.empty? : !obj
    end
  end

  def wait_until(timeout: Capybara.default_wait_time)
    do_instantly do
      Selenium::WebDriver::Wait.new(timeout: timeout).until do
        begin
          yield
        rescue
          false
        end
      end
    end
  end

  def click(selector)
    find(selector).click
  end

  def set_cookie(k, v)
    page.execute_script <<-eos
      (function (e,t,n){var r=new Date;r.setDate(r.getDate()+n);var i=escape(t)+(n==null?"":"; expires="+r.toUTCString());document.cookie=e+"="+i}
      (#{k.to_json}, #{v.to_json}));
    eos
  end

  def set_value_and_trigger_evts(selector, val)
    find(selector).set(val)
    page.execute_script("$('#{selector}').focusout().change().trigger('input')")
  end

  def verify_tweet_button(text)
    share_button_src = nil
    wait_until { share_button_src = find('.twitter-share-button')[:src] }
    assert_equal text, CGI.parse(URI.parse(share_button_src.gsub('#', '?')).query)['text'][0]
  end

  def driver
    page.driver.browser
  end

  def switch_to_window_and_execute
    wait_until { driver.window_handles.size == 2 }
    within_window(driver.window_handles.last) do
      yield
      driver.close
    end
  end

  def alert_accept(expected_msg = false)
    page.execute_script "window.alert = function(msg) { window.lastAlertMsg = msg; }"
    yield
    assert_equal(expected_msg, get_js('window.lastAlertMsg')) if expected_msg
  end

  def get_js(code)
    page.evaluate_script code
  end

  def jquery_selector(selector)
    "$('#{selector}')"
  end

  def get_val(selector)
    find(selector).value
  end

  def set_input_and_press_enter(selector, val)
    wait_til_element_visible(selector)
    page.execute_script("#{jquery_selector(selector)}.val('#{val}').trigger({type: 'keydown', which: 13}).trigger({ type: 'keypress', which: 13})")
  end

  def has_class?(el, class_name)
    klass = el[:class]
    return false if Helpers.blank?(klass)
    klass.split(' ').include?(class_name)
  end

  def wait_for_new_url(element_to_click = nil)
    old_url = current_url

    if element_to_click.nil?
      yield
    else
      element_to_click.click
    end

    sleep 1
    wait_until { current_url != old_url }
  end

  def refresh
    visit current_url
  end

  def wait_for_ajax
    wait_until { get_js '$.isReady && ($.active == 0)' }
  end

  def wait_til_element_visible(selector)
    has_css?(selector, visible: true)
    find(selector)
  end

  def scroll_to(selector)
    page.execute_script("#{jquery_selector('html, body')}.scrollTop(#{jquery_selector(selector)}.offset().top)")
  end

  %w(first all).each do |finder|
    define_method("#{finder}_with_wait") do |*args|
      has_css?(*args)
      send(finder.to_sym, *args)
    end
  end

  def visit_with_retries(url, retries: 5, wait_time: 10)
    raise 'only works with poltergeist' unless Capybara.javascript_driver == :poltergeist
    status = nil

    retries.times do |i|
      status = visit(url)['status']
      break if status == 'success'
      puts "visiting #{url} failed, attempting retry #{i + 1}/#{retries} in #{wait_time} second(s)"
      sleep wait_time
    end

    raise "visit #{url} failed" unless status == 'success'
  end

  def assert_text(text, el)
    assert_equal(text, el.text)
  end

  def assert_text_include(text, el)
    assert_equal(true, el.text.include?(text))
  end

  def parent(el)
    el.first(:xpath, './/..')
  end

  def click_by_text(selector, text, text_include: true, downcase: true)
    all_with_wait(selector, visible: true).find do |el|
      el_text = downcase ? el.text.downcase : el.text
      text_include ? el_text.include?(text) : el_text == text
    end.click
  end

  %w(has has_no).each do |prefix|
    define_method("assert_#{prefix}_css") do |*args|
      assert_equal(true, send("#{prefix}_css?", *args))
    end
  end

  def has_css_instant?(selector)
    do_instantly { has_css?(selector) }
  end

  def do_instantly
    old_time = Capybara.default_wait_time
    Capybara.default_wait_time = 0

    begin
      yield
    rescue => e
      raise(e)
    ensure
      Capybara.default_wait_time = old_time
    end
  end
end
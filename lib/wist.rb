module Wist
  require 'selenium-webdriver'
  require 'cgi'
  require 'capybara'
  require 'common_assert'

  def self.included(klass)
    klass.include CommonAssert
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  class << self
    attr_accessor(:wait_time_method)
  end

  self.wait_time_method = if defined?(Capybara.default_max_wait_time)
    :default_max_wait_time
  else
    :default_wait_time
  end

  module Helpers
    module_function

    def blank?(obj)
      obj.respond_to?(:empty?) ? obj.empty? : !obj
    end
  end

  def wait_until(timeout: false)
    do_instantly do
      Selenium::WebDriver::Wait.new(timeout: timeout || @old_wait_time).until do
        begin
          yield
        rescue
          false
        end
      end
    end
  end

  def click(*args)
    find(*args).click
  end

  def set_value_and_trigger_evts(selector, val)
    find(selector).set(val)
    page.execute_script("$('#{selector}').focusout().blur().change().trigger('input')")
  end

  def verify_tweet_button(text)
    share_button_src = nil
    wait_until { share_button_src = find('.twitter-share-button')[:src] }
    common_assert_equal(CGI.parse(URI.parse(share_button_src.gsub('#', '?')).query)['text'][0], text)
  end

  def driver
    page.driver.browser
  end

  def switch_to_window_and_execute(new_window_lambda)
    within_window(window_opened_by(&new_window_lambda)) do
      yield
      driver.close
    end
  end

  def interact_with_confirm(accept = true)
    page.execute_script("window.confirm = function() { return #{accept.to_json} }")
  end

  def alert_accept(expected_msg = false)
    page.execute_script "window.alert = function(msg) { window.lastAlertMsg = msg; }"
    yield

    wait_until do
      get_js('window.lastAlertMsg') == expected_msg
    end if expected_msg
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

  def process_el_or_selector(el_or_selector)
    if el_or_selector.is_a?(String)
      find(el_or_selector, visible: true)
    else
      el_or_selector
    end
  end

  def wait_for_new_url(element_to_click = nil)
    old_url = current_url

    if element_to_click.nil?
      yield
    else
      process_el_or_selector(element_to_click).click
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

  def assert_text(text, el_or_selector)
    common_assert_equal(process_el_or_selector(el_or_selector).text, text)
  end

  def assert_text_include(text, el)
    common_assert_equal(el.text.include?(text), true)
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
    define_method("assert_#{prefix}_css") do |selector, opt = {}|
      opt[:visible] = true if opt[:visible].nil?
      common_assert_equal(send("#{prefix}_css?", selector, opt), true)
    end
  end

  def has_css_instant?(*args)
    do_instantly { has_css?(*args) }
  end

  def get_capybara_wait_time
    Capybara.public_send(Wist.wait_time_method)
  end

  def do_instantly
    lambda do
      default_max_wait_time = get_capybara_wait_time
      @old_wait_time = default_max_wait_time if default_max_wait_time > 0
    end.()
    Capybara.public_send("#{Wist.wait_time_method}=", 0)

    begin
      yield
    rescue => e
      raise(e)
    ensure
      Capybara.public_send("#{Wist.wait_time_method}=", @old_wait_time)
    end
  end

  def assert_el_has_link(selector, link)
    common_assert_equal(get_js("$('#{selector}').attr('href')"), link)
  end
end

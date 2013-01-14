module Wist
  def self.included(base)
    require 'selenium-webdriver'
    require 'cgi'
    const_set :WAIT, Selenium::WebDriver::Wait.new(timeout: 20)
  end

  def wait_until(&block)
    WAIT.until &block
  end

  def click(selector)
    find(selector).click
  end

  def verify_tweet_button(text)
    assert_equal text, CGI.parse(URI.parse(find('.twitter-share-button')[:src].gsub('#', '?')).query)['text'][0]
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
    sleep 0.5
    alert = driver.switch_to.alert
    assert alert.text.include?(expected_msg) if expected_msg
    alert.accept
  end

  def get_js(code)
    page.execute_script("return #{code}")
  end

  def jquery_selector(selector)
    "$('#{selector}')"
  end

  def get_val(selector)
    get_js "#{jquery_selector selector}.val()"
  end

  def has_class(selector, class_name)
    get_js "#{jquery_selector selector}.hasClass('#{class_name}')"
  end

  def wait_for_new_url(element_to_click)
    old_url = current_url
    element_to_click.click
    sleep 1
    wait_until { current_url != old_url }
  end

  def refresh
    visit current_path
  end

  def element_displayed?(selector)
    find(selector).visible?
  end

  def wait_for_ajax
    wait_until { get_js '$.isReady && ($.active == 0)' }
  end

end
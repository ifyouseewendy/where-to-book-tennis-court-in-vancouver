class RmdHubScraper
  COOKIES = 'cookies/rmd_hub'

  def initialize
    @venue = :rmd_hub
    @vacancies = Vacancies.new
    @login = VENUES.at(@venue)['login']
    @link = VENUES.at(@venue)['link']
    @visible_days = VENUES.at(@venue)['visibleDays']
  end

  def run
    options = Selenium::WebDriver::Chrome::Options.new(args: [])
    #  options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    driver = Selenium::WebDriver.for(:chrome, options:)
    # https://www.selenium.dev/documentation/webdriver/waits/#implicit-wait
    driver.manage.timeouts.implicit_wait = 10

    handle_login(driver)

    today = Date.today
    @visible_days.times do |offset|
      date = today + offset

      @vacancies.concat(collect_vacancies(date, driver))
    end

    @vacancies
  ensure
    driver.quit if driver
  end

  private

  def collect_vacancies(date, driver)
    puts "##{@venue} Fetching calendar page for #{date}"

    url = "#{@link}&date=#{date}"
    driver.get(url)
    # File.write("#{date}.html", driver.page_source)

    # <div class="resource-session" data-payment-type="cash" data-availability="true" data-max-slots-doubles="0" data-max-slots-singles="0" data-resource-interval="30" data-session-id="821c3382-95b6-4021-93ae-8398708c715d" data-capacity="4" data-end-time="810" data-start-time="750" data-slot-key="97c52ee6-2c32-4a7a-b42e-b69d5f111f88821c3382-95b6-4021-93ae-8398708c715d750" data-session-cost="17.5" data-cost-from="17.5" data-session-member-cost="0" data-session-guest-cost="0" style="margin-top: 0px;">
    elements = driver.find_elements(css: 'div[data-availability="true"]')
    elements.map do |element|
      start_time = date.to_time + element.attribute('data-start-time').to_i
      end_time = date.to_time + element.attribute('data-end-time').to_i
      court_info = element.find_element(xpath: './ancestor::div[@class="resource"]').attribute('data-resource-name')
      Vacancy.new(
        venue: @venue,
        date:,
        start_time:,
        end_time:,
        court_info:
      )
    rescue StandardError => e
      # File.write("#{date}.new.html", driver.page_source)
      raise e
    end
  end

  def handle_login(driver)
    need_fresh_login = false
    if ENV['ENV'] == 'test'
      need_fresh_login = true
    elsif File.exist?(COOKIES)
      load_cookies(driver, COOKIES)
      user_name = driver.find_element(css: '.user-name').text
      if user_name == 'Nicholas'
        puts "##{@venue} Reuse cookies"
      else
        need_fresh_login = true
      end
    else
      need_fresh_login = true
    end
    fresh_login(driver) if need_fresh_login
  end

  def fresh_login(driver)
    puts "##{@venue} Fresh login"
    driver.get(@login)
    driver.find_element(css: '#EmailAddress').send_keys(ENV['RMD_HUB_ACCOUNT'])
    driver.find_element(css: '#Password').send_keys(ENV['RMD_HUB_PASSWORD'])
    driver.find_element(css: '#signin-btn').click
    store_cookies(driver)
  end

  def store_cookies(driver)
    File.write(COOKIES, Marshal.dump(driver.manage.all_cookies))
    puts "##{@venue} Store cookies"
  end

  def load_cookies(driver, cookies)
    cookies = Marshal.load(File.read(cookies))
    cookies.each do |cookie|
      driver.manage.add_cookie(cookie)
    end
    puts "##{@venue} Load cookies from #{COOKIES} successfully"
  end

  # Simply driver.get(url) and search element by driver.find_element causes
  # as the vacancy/slot is rendered through JS on the page.
  #
  #   Selenium::WebDriver::Error::StaleElementReferenceError: stale element reference: element is not attached to the page document
  #
  # This method sets an explicit timeout on waiting the ajax to be finished on the page
  # def get_with_timeout(driver, url)
  #   driver.get(url)
  #   wait = Selenium::WebDriver::Wait.new(timeout: 10)
  #
  #   wait.until do
  #     found = !!driver.find_element(css: '.ajax-wrapper')
  #     !found
  #   end
  # end
end

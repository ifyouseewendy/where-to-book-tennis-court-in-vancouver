class RmdHubScraper
  COOKIES = 'cookies/rmd_hub.yml'

  def initialize
    @venue = :rmd_hub
    @vacancies = Vacancies.new
    @login = VENUES.at(@venue)['login']
    @link = VENUES.at(@venue)['link']
  end

  def run
    cal_page = request_calendar_page

    # today
    # date = Time.now.to_date
    # @vacancies.concat(collect_vacancies(date, cal_page))
    #
    # # following days
    # cal_page.links_with(href: /calendarDayView.do/).each do |link|
    #   # href: iYear=2022&iMonth=10&iDate=29
    #   matched = link.href.match(/iYear=(?<year>\d{4})&iMonth=(?<month>\d+)&iDate=(?<day>\d+)/)
    #   _, year, month, day = matched.to_a
    #   month = month.to_i + 1
    #
    #   date = Date.parse("#{year}-#{month}-#{day} #{Time.now.zone}")
    #   cal_page = link.click
    #   @vacancies.concat(collect_vacancies(date, cal_page))
    # end

    @vacancies
  end

  private

  def request_calendar_page
    agent = Mechanize.new

    if ENV['ENV'] != 'test' && File.exist?(COOKIES)
      agent.cookie_jar.load(COOKIES, session: true)
      puts "##{@venue} Load cookies from #{COOKIES} successfully"

      page = agent.get(@link)

      # TODO
      unless page.uri.to_s.end_with?('error.do')
        puts "##{@venue} Reuse cookies"
        return page
      end
    end

    page = fresh_login(agent)
    agent.get(@link)
  end

  def fresh_login(agent)
    puts "##{@venue} Fresh login"
    login_page = agent.get(@login)

    form = login_page.form
    form.EmailAddress = ENV['RMD_HUB_ACCOUNT']
    form.Password = ENV['RMD_HUB_PASSWORD']

    page = agent.submit(form, form.buttons.first)

    # new_page = agent.get(page.uri)
    require 'pry-byebug'
    binding.pry

    form = page.form
    headers = {
      'origin' => 'https://auth.clubspark.ca',
      'referer' => 'https://auth.clubspark.ca/',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36'
    }
    new_page = agent.submit(form, form.buttons.first, headers)

    agent.cookie_jar.save(COOKIES, session: true) if ENV['ENV'] != 'test'
    puts "##{@venue} Store cookies"

    new_page
  end
end

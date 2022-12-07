class BTCScraper
  COOKIES = 'cookies/btc.yml'

  def initialize
    @venue = :btc
    @vacancies = Vacancies.new
    @login = VENUES.at(:btc)['login']
    @link = VENUES.at(:btc)['link']
  end

  def run
    # today
    date = Time.now.to_date
    cal_page = request_calendar_page(date)
    @vacancies.concat(collect_vacancies(date, cal_page))

    links = cal_page.links_with(href: /calendarDayView.do/)

    # following days
    links.each do |link|
      # href: iYear=2022&iMonth=10&iDate=29
      matched = link.href.match(/iYear=(?<year>\d{4})&iMonth=(?<month>\d+)&iDate=(?<day>\d+)/)
      _, year, month, day = matched.to_a
      month = month.to_i + 1

      date = Date.parse("#{year}-#{month}-#{day} #{Time.now.zone}")
      cal_page = link.click
      @vacancies.concat(collect_vacancies(date, cal_page))
    end

    @vacancies.sort_and_combine
  end

  private

  NON_BREAKING_SPACE = "\u00A0"

  def collect_vacancies(date, cal_page)
    puts "##{@venue} Fetching calendar page for #{date}"

    vacancies = []
    table = cal_page.search('table.calendar').first
    courts = table.search('tr:first-child th').map(&:text).map(&:strip)

    matrix = []
    table.search('tr td').map(&:text).each_slice(courts.count) do |slice|
      matrix << slice.map do |raw_text|
        text = raw_text.gsub(NON_BREAKING_SPACE, '').strip

        # "09:00 AMHai Ji (P&P) vs Wenjing Lu (NM)"
        # "08:00 AM Book"
        matched = text.match(/(?<time>\d{2}:\d{2} [A|P]M)(?<others>.*)/)
        if matched
          {
            time: matched[:time],
            others: matched[:others].strip
          }
        else
          {}
        end
      end
    end

    last_row_starts_at = infer_start_time_for_empty_spot(date, matrix.last)
    day_ends_at = if last_row_starts_at.min == 30
                    last_row_starts_at + 30 * 60 # half an hour
                  else
                    last_row_starts_at + 60 * 60 # an hour
                  end

    (0...courts.count).each do |col|
      row = 0
      while row < matrix.length
        slot = matrix[row][col]

        if slot[:others] != 'Book'
          row += 1
          next
        end

        start_time = Time.parse("#{date} #{slot[:time]}")
        j = row + 1
        j += 1 while j < matrix.length && matrix[j][col][:others] == 'Book'

        end_time = if j == matrix.length
                     day_ends_at
                   elsif matrix[j][col].empty?
                     infer_start_time_for_empty_spot(date, matrix[j])
                   else
                     Time.parse("#{date} #{matrix[j][col][:time]}")
                   end

        court_info = courts[col]

        vacancies << Vacancy.new(
          venue: @venue,
          date:,
          start_time:,
          end_time:,
          court_info:
        )

        row = j
      end
    end

    vacancies
  end

  def request_calendar_page(date)
    agent = Mechanize.new

    if ENV['ENV'] != 'test' && File.exist?(COOKIES)
      agent.cookie_jar.load(COOKIES, session: true)
      puts "##{@venue} Load cookies from #{COOKIES} successfully"

      page = agent.get("#{@link}&iYear=#{date.year}&iMonth=#{date.month - 1}&iDate=#{date.day}")

      unless page.uri.to_s.end_with?('error.do')
        puts "##{@venue} Reuse cookies"
        return page
      end
    end

    home_page = fresh_login(agent)
    home_page.link_with(href: /calendarDayView.do/).click
  end

  def fresh_login(agent)
    puts "##{@venue} Fresh login"
    login_page = agent.get(@login)

    form = login_page.form
    form.userId = ENV['BTC_ACCOUNT']
    form.password = ENV['BTC_PASSWORD']

    home_page = agent.submit(form, form.buttons.first)

    agent.cookie_jar.save(COOKIES, session: true) if ENV['ENV'] != 'test'
    puts "##{@venue} Store cookies"

    home_page
  end

  def infer_start_time_for_empty_spot(date, row)
    start_time = row.map { |h| h[:time] }.compact.sort.last
    Time.parse("#{date} #{start_time}")
  end
end

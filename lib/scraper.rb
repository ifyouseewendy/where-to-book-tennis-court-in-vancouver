require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'dotenv/load'
require_relative './vacancy'
require_relative './vacancies'

BTC_LOGIN = 'https://www.burnabytennis.ca/burnaby/home/login.do'

class Scraper
  attr_reader :vacancies

  def initialize
    @vacancies = Vacancies.new
  end

  def run
    agent = Mechanize.new
    login_page = agent.get(BTC_LOGIN)

    form = login_page.form
    form.userId = ENV['ACCOUNT']
    form.password = ENV['PASSWORD']

    home_page = agent.submit(form, form.buttons.first)

    # today
    date = Time.now.to_date
    cal_page = home_page.link_with(href: /calendarDayView.do/).click
    @vacancies.concat(collect_vacancies(date, cal_page))

    cal_page.links_with(href: /calendarDayView.do/).each do |link|
      # href: iYear=2022&iMonth=10&iDate=29
      matched = link.href.match(/iYear=(?<year>\d{4})&iMonth=(?<month>\d+)&iDate=(?<day>\d+)/)
      _, year, month, day = matched.to_a
      month = month.to_i + 1

      date = Date.parse("#{year}-#{month}-#{day} #{Time.now.zone}")
      cal_page = link.click
      @vacancies.concat(collect_vacancies(date, cal_page))
    end
  end

  def show_vacancies
    @vacancies.sort!
    @vacancies.to_s
  end

  private

  NON_BREAKING_SPACE = "\u00A0"

  def collect_vacancies(date, cal_page)
    vacancies = []
    table = cal_page.search('table.calendar').first
    courts = table.search('tr:first-child th').map(&:text).map(&:strip)

    matrix = []
    table.search('tr td').map(&:text).each_slice(courts.count) do |slice|
      matrix << slice.map do |raw_text|
        text = raw_text.gsub("\u00A0", '').strip

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
                     Time.parse("#{date + 1} 00:00 AM")
                   else
                     Time.parse("#{date} #{matrix[j][col][:time]}")
                   end

        court_info = courts[col]

        vacancies << Vacancy.new(
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
end

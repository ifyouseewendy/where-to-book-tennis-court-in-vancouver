require 'mechanize'
require_relative './venues'
require_relative './vacancy'
require_relative './vacancies'

class COQScraper
  COOKIES = 'cookies/coq.yml'

  def initialize
    @venue = :coq
    @vacancies = Vacancies.new
    @link = VENUES.at(@venue)['link']
  end

  def run
    cal_page = request_calendar_page

    date = Date.today
    @vacancies.concat(collect_vacancies(date, cal_page))

    cal_page.links_with(href: /calendarDayView.do/).each do |link|
      matched = link.href.match(/iYear=(?<year>\d{4})&iMonth=(?<month>\d+)&iDate=(?<day>\d+)/)
      _, year, month, day = matched.to_a
      month = month.to_i + 1

      date = Date.parse("#{year}-#{month}-#{day} #{Time.now.zone}")
      cal_page = link.click
      @vacancies.concat(collect_vacancies(date, cal_page))
    end

    @vacancies
  end

  private

  NON_BREAKING_SPACE = "\u00A0"

  def request_calendar_page
    agent = Mechanize.new
    agent.get(@link)
  end

  def collect_vacancies(date, cal_page)
    puts "##{@venue} Fetching calendar page for #{date}"
    vacancies = []
    table = cal_page.search('table.calendar').first
    courts = table.search('tr:first-child th').map(&:text).map(&:strip)

    matrix = []
    table.search('tr td').map(&:text).each_slice(courts.count) do |slice|
      matrix << slice.map do |raw_text|
        text = raw_text.gsub(NON_BREAKING_SPACE, '').strip

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

        if slot.empty?
          row += 1
          next
        end

        start_time = Time.parse("#{date} #{slot[:time]}")
        j = row
        duration = 0
        while j < matrix.length && !matrix[j][col].empty?
          duration += 0.5
          j += 1
        end

        end_time = start_time + duration * 3600

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
end

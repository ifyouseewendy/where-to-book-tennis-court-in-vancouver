class RmdHubScraper
  def initialize
    @venue = :rmd_hub
    @vacancies = Vacancies.new
    @link = VENUES.at(@venue)['link']
    @visible_days = VENUES.at(@venue)['visibleDays']
  end

  def run
    today = Date.today
    start_date = today
    end_date = today + @visible_days - 1

    puts "##{@venue} Fetching calendar data from #{start_date} to #{end_date}"
    url = "#{@link}&startDate=#{start_date}&endDate=#{end_date}"
    uri = URI(url)

    res = Net::HTTP.get_response(uri)
    raise "Fail to request #{uri}: #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    data = JSON.parse(res.body)
    now = Time.now

    vacancies = []
    data['Resources'].each do |resource|
      court_info = resource['Name']

      resource['Days'].each do |day|
        date = Date.parse(day['Date'])
        sessions = day['Sessions'].select { |h| h['Capacity'] > 0 }
        sessions.each do |session|
          start_time = date.to_time + session['StartTime'] * 60
          end_time = date.to_time + session['EndTime'] * 60
          next if now > start_time

          vacancies << Vacancy.new(
            venue: @venue,
            date:,
            start_time:,
            end_time:,
            court_info:
          )
        end
      end
    end

    @vacancies.concat(vacancies)

    @vacancies.sort_and_combine
  end
end

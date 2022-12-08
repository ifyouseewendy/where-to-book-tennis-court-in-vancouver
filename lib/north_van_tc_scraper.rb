# Scraping strategy:
#
# 1. GET endpoint["homepage"] to find the booking link, which contains the 'calendarId' and 'widgetId'
# 2. Follow the booking link, we'll get the cookies and form submit token
# 3. POST endpoint["court_vacancies"] to request the vacancies
class NorthVanTcScraper
  def initialize
    @venue = :north_van_tc
    @vacancies = Vacancies.new
    @endpoint = VENUES.at(@venue)['endpoint']
    @visible_days = VENUES.at(@venue)['visibleDays']
  end

  def run
    agent = Mechanize.new

    query_params, booking_page_link = fetch_query_params(agent)

    puts "##{@venue} Visiting booking page"
    page = booking_page_link.click

    form_submit_token = fetch_form_submit_token(page)
    cookies = fetch_cookies(agent)

    vacancies = fetch_court_vacancies(query_params, cookies, form_submit_token)

    @vacancies.concat(vacancies)

    @vacancies.sort_and_combine
  end

  private

  def fetch_query_params(agent)
    puts "##{@venue} Visiting homepage"
    page = agent.get(@endpoint['homepage'])

    # https://nvrc.perfectmind.com/23734/Clients/BookMe4BookingPages/BookingCoursesPage?calendarId=0291bc47-4b59-4d4a-8533-dc026a6c3956&widgetId=a28b2c65-61af-407f-80d1-eaa58f30a94a&embed=False
    booking_page_link = page.link_with(href: /BookingCoursesPage/)
    query_params = {}
    booking_page_link.href.split('?').last.split('&').each do |query|
      k, v = query.split('=')
      next unless %w[calendarId widgetId].include?(k)

      query_params[k] = v
    end

    [query_params, booking_page_link]
  end

  def fetch_form_submit_token(page)
    page.forms.first['__RequestVerificationToken']
  end

  def fetch_cookies(agent)
    %w[PMSessionId __RequestVerificationToken].map do |key|
      value = agent.cookies.find { |c| c.name == key }.value
      "#{key}=#{value}"
    end
  end

  def fetch_court_vacancies(query_params, cookies, form_submit_token)
    puts "##{@venue} Fetching court vacancies"
    url = URI(@endpoint['court_vacancies'])

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Cookie'] = cookies.join('; ')
    request['Content-Type'] = 'application/x-www-form-urlencoded'

    body = query_params.merge(
      page: 0,
      bookingMode: 0,
      __RequestVerificationToken: form_submit_token
    ).map { |k, v| "#{k}=#{v}" }
    request.body = body.join('&')

    response = https.request(request)
    raise "Fail to request #{url}: #{response.code}" unless response.code == '200'

    data = JSON.parse(response.body)

    vacancies = []
    data.each do |slot|
      next if slot['BookButtonText'] == 'Closed'

      date = Date.strptime(slot['OccurrenceMinStartDate'], '%m/%d/%y')
      raw_start_time = slot['FormattedStartTime']
      start_time = Time.parse("#{date} #{raw_start_time}")
      raw_end_time = slot['FormattedEndTime']
      end_time = Time.parse("#{date} #{raw_end_time}")

      court_info = slot['Facility']
      court_info = 'Unknown' if court_info.empty?

      vacancies << Vacancy.new(
        venue: @venue,
        date:,
        start_time:,
        end_time:,
        court_info:
      )
    end

    vacancies
  end
end

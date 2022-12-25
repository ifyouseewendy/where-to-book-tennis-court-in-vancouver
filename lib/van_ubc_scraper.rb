# Scraping strategy:
#
# 1. POST endpoint["court_lists"] to fetch the list of court information
# 2. GET endpoint["court_page"] to get cookies (PMSessionId, __RequestVerificationToken), form submit
#    token (__RequestVerificationToken) and duration ids
# 3. POST endpoint["court_vacancies"] with the cookies, form submit token to pass the server side check
#    on [ASP AntiForgery](https://learn.microsoft.com/en-us/dotnet/api/system.web.helpers.antiforgery.validate)
class VanUbcScraper
  def initialize
    @venue = :van_ubc
    @vacancies = Vacancies.new
    @endpoint = VENUES.at(@venue)['endpoint']
    @visible_days = VENUES.at(@venue)['visibleDays']
  end

  def run
    courts = fetch_court_lists

    today = Date.today
    agent = Mechanize.new

    courts.each do |court|
      page = get_court_page(agent, court, today)
      cookies = fetch_cookies(agent)
      form_submit_token = fetch_form_submit_token(page)
      duration_ids = fetch_duration_ids(page)

      vacancies = fetch_court_vacancies(court, cookies, form_submit_token, duration_ids)
      @vacancies.concat(vacancies)
    end

    @vacancies.sort_and_combine
  end

  def fetch_court_vacancies(court, cookies, form_submit_token, duration_ids)
    puts "##{@venue} ##{court[:name]} Fetching court vacancies"
    url = URI(@endpoint['court_vacancies'])

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request['Cookie'] = cookies.join('; ')
    # 2022-12-07T20:26:16.474Z
    date = Time.now.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    h = {
      "facilityId": court[:id],
      "date": '2022-12-07T16:49:18.395Z',
      "daysCount": 7,
      "duration": 60,
      "serviceId": court[:service_id],
      "__RequestVerificationToken": form_submit_token
    }
    body = h.map { |k, v| "#{k}=#{v}" }
    duration_ids.each do |duration_id|
      body.push("durationIds[]=#{duration_id}")
    end
    request.body = body.join('&')
    response = https.request(request)
    raise "Fail to request #{url}: #{response.code}" unless response.code == '200'

    data = JSON.parse(response.body)
    now = Time.now

    vacancies = []

    data['availabilities'].each do |availability|
      raw_date = availability['Date'].match(/\d+/)[0]
      date = DateTime.strptime(raw_date, '%Q').to_date

      availability['BookingGroups'].each do |bg|
        bg['AvailableSpots'].each do |spot|
          raw_time = spot['Time'].values_at('Hours', 'Minutes', 'Seconds').join(':')
          start_time = Time.parse("#{date} #{raw_time}")
          next if now > start_time

          duration = spot['Duration']['TotalMinutes'] / 60.0
          end_time = start_time + duration * 60 * 60
          vacancies << Vacancy.new(
            venue: @venue,
            date:,
            start_time:,
            end_time:,
            court_info: court[:name]
          )
        end
      end
    end

    vacancies
  end

  def fetch_court_lists
    puts "##{@venue} Fetching court lists"
    url = URI(@endpoint['court_lists'])

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    today = Date.today.to_s
    request.body = "take=20&page=1&pageSize=20&StartDate=#{today}"

    response = https.request(request)
    raise "Fail to request #{url}: #{response.code}" unless response.code == '200'

    data = JSON.parse(response.read_body)

    courts = []
    service_id = data['serviceFilterOptions'].find { |h| h['Name'].index('Facility Rental') }['ID']
    data['facilities'].each do |court|
      next if court['Name'].index('Outdoor')

      courts << {
        id: court['ID'],
        name: court['Name'],
        service_id:
      }
    end

    courts
  end

  def get_court_page(agent, court, date)
    puts "##{@venue} ##{court[:name]} Visiting court page"
    url = @endpoint['court_page'].sub('{FACILITY_ID}', court[:id]).sub('{DATE}', date.to_s)

    agent.get(url)
  end

  def fetch_cookies(agent)
    %w[PMSessionId __RequestVerificationToken].map do |key|
      value = agent.cookies.find { |c| c.name == key }.value
      "#{key}=#{value}"
    end
  end

  def fetch_form_submit_token(page)
    page.forms.first['__RequestVerificationToken']
  end

  # The only way I could find durations ids are in the script section of the page.
  # I'm using quite a naive way to parse the html
  #
  #
  # Eg.
  #
  # var viewModel = new MainViewModel({
  #     facilityId: 'c117a102-0ba0-4aa8-b8cf-eb8a1480be55',
  #     widgetId: '',
  #     calendarId: '',
  #     services: [{"StartsEvery":60,"Durations":[{"Duration":60.0,"FeeType":0,"DurationIDs":["e483fbaa-3747-43aa-b1e4-011012c5c9ca","7bde72bd-3728-4a06-84c4-04e995dd7dc2","6e5b85e7-0a0a-46bb-b073-07b18aa6aca2","b4f00b4c-ef43-4a29-af58-1a26f7fe8ab4","b1141148-a7aa-486b-be4f-26bbe90562a0","98350132-4e11-41e9-bb12-436b1b21aadb","ea51cd3a-ce92-4334-88e4-43c69eedf695","b82d8c54-09fb-4de8-bf6e-4cb533dd5fb6","aab95585-d76b-4826-a884-4e40b4215b5e","a463cd06-944f-4bb0-a0de-62386f6da975","8ab96630-5c50-4ae1-a9ff-699ad61a14bd","1f96002e-24e7-42fd-8aa1-75f5768fd43a","357e7b04-cf27-4731-9ee3-7af7641702c6","5867dd7c-2379-47e3-97ff-7bfbd5709a7f","c29b63a6-cca3-4465-aedd-83446025328c","399ebfed-22c3-40da-bd40-8421126af64c","418e1d4b-039f-4a07-abed-90fa25f469c5","1e1c3762-ed15-4486-a4c7-954386d52e76","eff943f9-8a5d-49c3-b534-96c7c7783fdd","a3c22618-ad9a-4898-9002-bc0b00a821ae","1f049b1f-6f83-489e-85d8-de2536435157","6ad64928-5cd2-42f0-bea4-de54a1d65c5b","0a40a1a6-38b9-4b77-adaa-eb365c34bda3","84f98ed4-e87f-4b17-afa8-ef16f5fdc1b8"]
  #     ...
  def fetch_duration_ids(page)
    i = page.body.index('DurationIDs')
    st = page.body[i..].index('[')
    ed = page.body[i..].index(']')

    page.body[i..][st + 1...ed].split(',').map { |s| s.delete('"') }
  end
end

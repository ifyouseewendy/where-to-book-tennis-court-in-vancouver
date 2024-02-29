class SurreyTTCScraper
  def initialize
    @venue = :surrey_ttc
    @vacancies = Vacancies.new
    @site = VENUES.at(@venue)['site']
    @visible_days = VENUES.at(@venue)['visibleDays']
  end

  def fetch_link(url)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')

    driver = Selenium::WebDriver.for :chrome, options: options

    pattern = "admin-ajax.php"

    driver.get(url)
    sleep 5
    retries = 0
    begin
      # Execute JavaScript to extract network requests
      script = <<~HERE
        var resources = [];
        performance.getEntriesByType("resource").forEach(function(entry) {
          if (entry.name.includes("#{pattern}")) {
            resources.push(entry.name);
          }
        });
        return resources;
      HERE
      resources = driver.execute_script(script)

      raise "No link found" if resources.count == 0

      return resources[0]
    rescue StandardError => e
      if e.message == "No link found" && retries < 3
        retries += 1
        sleep 3
        retry
      end

      raise "Fail to fetch link for #{@venue}: #{e}"
    ensure
      # Quit the WebDriver session
      driver.quit if driver
    end
  end

  def run
    today = Date.today

    link = fetch_link(@site)

    @visible_days.times do |offset|
      date = today + offset

      uri = URI(link.sub(/date=\d+8/, "date=#{date.to_s.delete('-')}"))

      puts "##{@venue} Fetching calendar data for #{date}"
      res = Net::HTTP.get_response(uri)
      raise "Fail to request #{uri}: #{res.code}" unless res.is_a?(Net::HTTPSuccess)

      lines = res.body.split("\r\n").map(&:strip).reject(&:empty?)

      # <ul>
      # <li class=\"\">6:00 am                    </li>
      # <li class=\"\">6:30 am                    </li>
      # ...
      # </ul>
      #
      # <div class="court_item">
      #   <div class="court_header">
      #     <h4>Court 1</h4>
      #   </div>
      #   <ul>
      #     <li class="">
      #     </li>
      #     <li class="">
      #       <div class=\"booking_box booking_size_20 blocked_item\"></div>
      #     </li>
      #     ..
      #   </ul>
      # </div>
      # <div class="court_item">
      #   <div class="court_header">
      #     <h4>Court 2</h4>
      #   </div>
      #   <ul>
      #     <li class="">
      #     </li>
      #     <li class="">
      #       <div class=\"booking_box booking_size_20 blocked_item\"></div>
      #     </li>
      #     <li class="prime_time"><button class="book_button" data-date="20221206" data-time="23.5" data-court="23" data-date_str="12/06/2022" data-time_str="23:30" data-court_str="Hard Court 6">Book</button></li>"
      #     <li class=""></li>
      #     ...
      #   </ul>
      # </div>

      i = lines.find_index { |line| line.start_with?('</ul>') }
      _time_lines = lines[0..i]

      court_lines = lines[i + 1..]
      indicies_with_book_buttons = court_lines.each_index.select { |ii| court_lines[ii].index('book_button') }

      slots = []
      indicies_with_book_buttons.each do |idx|
        line = court_lines[idx]

        time = line.match(/data-time_str="(?<time>\d{1,2}:\d{2})"/)[:time]
        start_time = Time.parse("#{date} #{time}")
        duration = 0.5
        duration += 0.5 if court_lines[idx + 1] == '<li class="prime_time"></li>'
        end_time = start_time + duration * 60 * 60
        court = line.match(/data-court_str="(?<court>.*)"/)[:court]
        slots << {
          start_time:,
          end_time:,
          court:
        }
      end

      vacancies = slots.map do |slot|
        Vacancy.new(
          venue: @venue,
          date:,
          start_time: slot[:start_time],
          end_time: slot[:end_time],
          court_info: slot[:court]
        )
      end
      @vacancies.concat(vacancies)
    end

    @vacancies.sort_and_combine
  end
end

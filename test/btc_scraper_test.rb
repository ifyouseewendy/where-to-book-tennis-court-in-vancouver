require_relative './test_helper'

class BTCScraperTest < Minitest::Test
  def setup
    @scraper = BTCScraper.new
  end

  def test_run
    VCR.use_cassette('btc_request_calendar_page') do
      vacancies = @scraper.run
      assert_equal 6, vacancies.count

      vacancy = vacancies.to_a.first
      assert_equal 'btc: Thu Dec 01, 2022 09:00 AM - 10:00 AM (1.0h) Indoor Court 3', vacancy.to_s
    end
  end
end

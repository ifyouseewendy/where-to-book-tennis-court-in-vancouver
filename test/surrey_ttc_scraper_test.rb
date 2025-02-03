require_relative './test_helper'

class SurreyTTCScraperTest < Minitest::Test
  def setup
    @scraper = SurreyTTCScraper.new
  end

  def test_run
    VCR.use_cassette('surrey_ttc_request_calendar_page') do
      Timecop.freeze(Date.parse('2025-01-23')) do
        vacancies = @scraper.run
        assert_equal 14, vacancies.count
      end
    end
  end
end

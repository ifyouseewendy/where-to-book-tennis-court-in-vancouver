require_relative './test_helper'

class SurreyTTCScraperTest < Minitest::Test
  def setup
    @scraper = SurreyTTCScraper.new
  end

  def test_run
    VCR.use_cassette('surrey_ttc_request_calendar_page') do
      Timecop.freeze(Date.parse('2022-12-06')) do
        vacancies = @scraper.run
        assert_equal 35, vacancies.count
      end
    end
  end
end

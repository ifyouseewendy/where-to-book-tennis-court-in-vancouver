require_relative './test_helper'

class SurreyTTCScraperTest < Minitest::Test
  def setup
    @scraper = SurreyTTCScraper.new
  end

  def test_run
    VCR.use_cassette('surrey_ttc_request_calendar_page') do
      vacancies = @scraper.run
      assert_equal 56, vacancies.count
    end
  end
end

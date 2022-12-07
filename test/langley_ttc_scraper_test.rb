require_relative './test_helper'

class LangleyTTCScraperTest < Minitest::Test
  def setup
    @scraper = LangleyTTCScraper.new
  end

  def test_run
    VCR.use_cassette('langley_ttc_request_calendar_page') do
      Timecop.freeze(Date.parse('2022-12-06')) do
        vacancies = @scraper.run
        assert_equal 37, vacancies.count
      end
    end
  end
end

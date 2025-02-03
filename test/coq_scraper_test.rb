require_relative './test_helper'

class COQScraperTest < Minitest::Test
  def setup
    @scraper = COQScraper.new
  end

  def test_run
    VCR.use_cassette('coq_request_calendar_page') do
      Timecop.freeze(Date.parse('2022-12-01')) do
        vacancies = @scraper.run
        assert_equal 13, vacancies.count
      end
    end
  end
end

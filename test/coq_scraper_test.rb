require_relative './test_helper'

class COQScraperTest < Minitest::Test
  def setup
    @scraper = COQScraper.new
  end

  def test_run
    VCR.use_cassette('coq_request_calendar_page') do
      vacancies = @scraper.run
      assert_equal 16, vacancies.count
    end
  end
end

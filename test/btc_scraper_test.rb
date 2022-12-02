require_relative './test_helper'

class BTCScraperTest < Minitest::Test
  def setup
    @scraper = BTCScraper.new
  end

  def test_run
    VCR.use_cassette('btc_request_calendar_page') do
      vacancies = @scraper.run
      assert_equal 6, vacancies.count
    end
  end

  def test_run_checking_on_ends_at
    VCR.use_cassette('btc_request_calendar_page_ends_at_1100') do
      vacancies = @scraper.run
      assert_equal 11, vacancies.count
    end
  end
end

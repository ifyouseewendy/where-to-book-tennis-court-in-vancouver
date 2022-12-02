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

  # Court 5
  # [10:00 PM Book]
  # [10:30 PM Book]
  def test_run_btc_checking_on_ends_at
    VCR.use_cassette('btc_request_calendar_page_ends_at_1100') do
      vacancies = @scraper.run.to_a
      assert_equal 11, vacancies.count
      assert_equal '11:00 PM', vacancies[1][:end_time]
    end
  end

  # Court 5
  # [06:00 AM Book]
  # [] (nothing in this spot, but marked with color)
  def test_run_btc_blank_spot
    VCR.use_cassette('btc_request_calendar_page_blank_spot') do
      vacancies = @scraper.run.to_a
      assert_equal 11, vacancies.count
      assert_equal '07:00 AM', vacancies[2][:end_time]
    end
  end
end

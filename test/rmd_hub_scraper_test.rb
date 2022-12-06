require_relative './test_helper'

class RmdHubScraperTest < Minitest::Test
  def setup
    @scraper = RmdHubScraper.new
  end

  def test_run
    VCR.use_cassette('rmd_hub_request_calendar_page') do
      vacancies = @scraper.run
      assert_equal 6, vacancies.count
    end
  end
end

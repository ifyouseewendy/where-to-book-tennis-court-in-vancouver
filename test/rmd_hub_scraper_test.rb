require_relative './test_helper'

class RmdHubScraperTest < Minitest::Test
  def setup
    @scraper = RmdHubScraper.new
  end

  def test_run
    VCR.use_cassette('rmd_hub_request_calendar_page') do
      Timecop.freeze(Date.parse('2022-12-06')) do
        vacancies = @scraper.run
        assert_equal 45, vacancies.count
      end
    end
  end
end

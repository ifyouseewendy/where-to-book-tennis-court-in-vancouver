require_relative './test_helper'

class COQScraperTest < Minitest::Test
  def setup
    @scraper = COQScraper.new
  end

  def test_run
    VCR.use_cassette('coq_request_calendar_page') do
      vacancies = @scraper.run
      assert_equal 16, vacancies.count

      vacancy = vacancies.to_a.first
      assert_equal 'coq: Thu Dec 01, 2022 07:00 AM - 08:30 AM (1.5h) Court 5', vacancy.to_s
    end
  end
end

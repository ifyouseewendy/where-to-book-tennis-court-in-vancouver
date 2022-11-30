require_relative './test_helper'
require_relative '../lib/btc_scraper'

class BTCScraperTest < Minitest::Test
  def setup
    @scraper = BTCScraper.new
  end

  def test_run
    VCR.use_cassette('btc_login_and_book_courts') do
      vacancies = @scraper.run(to_a: true)
      assert_equal 19, vacancies.count

      vacancy = vacancies.first
      assert_equal 'btc: Tue Nov 29, 2022 07:00 PM - 07:30 PM (0.5h) Indoor Court 1', vacancy.to_s
    end
  end
end

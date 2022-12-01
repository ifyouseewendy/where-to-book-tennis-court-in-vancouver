require_relative './test_helper'
require 'btc_scraper'

class BTCScraperTest < Minitest::Test
  def setup
    @scraper = BTCScraper.new
  end

  def test_run
    VCR.use_cassette('btc_login_and_book_courts') do
      vacancies = @scraper.run(to_a: true)
      assert_equal 6, vacancies.count

      vacancy = vacancies.first
      assert_equal 'btc: Thu Dec 01, 2022 09:00 AM - 10:00 AM (1.0h) Indoor Court 3', vacancy.to_s
    end
  end
end

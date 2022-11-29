require_relative './test_helper'
require_relative '../lib/btc_scraper'

class TestMeme < Minitest::Test
  def setup
    @scraper = BTCScraper.new
  end

  def test_run
    VCR.use_cassette('login_and_book_courts') do
      vacancies = @scraper.run(to_a: true)
      assert_equal 12, vacancies.count

      vacancy = vacancies.first
      assert_equal 'btc: Tue Nov 29, 2022 01:00 PM - 01:30 PM (0.5h) Indoor Court 1', vacancy.to_s
    end
  end
end

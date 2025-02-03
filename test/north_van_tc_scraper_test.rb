require_relative './test_helper'

class NorthVanTcScraperTest < Minitest::Test
  def setup
    @scraper = NorthVanTcScraper.new
  end

  def skip_test_run
    VCR.use_cassette('north_van_tc_run') do
      Timecop.freeze('2022-12-08 12:11:10 -0800') do
        vacancies = @scraper.run
        assert_equal 34, vacancies.count
      end
    end
  end
end

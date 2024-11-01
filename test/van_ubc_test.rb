require_relative './test_helper'

class VanUbcScraperTest < Minitest::Test
  def setup
    @scraper = VanUbcScraper.new
  end

  def teardown; end

  def skip_test_run
    VCR.use_cassette('van_ubc_run') do
      Timecop.freeze('2022-12-07 21:23:02 -0800') do
        vacancies = @scraper.run
        assert_equal 44, vacancies.count
      end
    end
  end
end

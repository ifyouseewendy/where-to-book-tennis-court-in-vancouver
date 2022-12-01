require_relative './test_helper'

class RunnerTest < Minitest::Test
  def setup
    @scraper = Runner.new(btc: BTCScraper.new)
  end

  def test_run
    VCR.use_cassette('runner') do
      vacancies = @scraper.run

      assert vacancies.key?(:btc)
      btc_vacancies = vacancies[:btc]

      assert_equal 2, btc_vacancies.keys.count
    end
  end
end

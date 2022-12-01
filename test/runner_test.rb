require_relative './test_helper'

class RunnerTest < Minitest::Test
  def setup
    @scraper = Runner.new(
      btc: BTCScraper.new,
      coq: COQScraper.new
    )
  end

  def test_run
    VCR.use_cassette('runner') do
      vacancies = @scraper.run

      assert_equal 2, vacancies.count

      assert vacancies.key?(:btc)
      assert vacancies.key?(:coq)
    end
  end
end

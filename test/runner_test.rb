require_relative './test_helper'

class RunnerTest < Minitest::Test
  def setup
    @btc_scraper = BTCScraper.new
    @coq_scraper = COQScraper.new
    @scraper = Runner.new(
      btc: @btc_scraper,
      coq: @coq_scraper
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

  def test_error
    @btc_scraper.expects(:run).returns({})
    @coq_scraper.expects(:run).raises(RuntimeError, 'error')

    vacancies = @scraper.run
    assert vacancies.key?(:btc)
    assert vacancies.key?(:coq)
    assert vacancies[:coq][:errored]
  end
end

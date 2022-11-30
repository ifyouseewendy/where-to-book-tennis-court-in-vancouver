require_relative './test_helper'
require_relative '../lib/runner'

class RunnerTest < Minitest::Test
  def setup
    @scraper = Runner.new(btc: BTCScraper.new)
  end

  def test_run
    VCR.use_cassette('runner') do
      vacancies = @scraper.run
    end
  end
end

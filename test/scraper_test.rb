require_relative './test_helper'

class TestMeme < Minitest::Test
  def setup
    @scraper = Scraper.new
  end

  def test_truth
    assert true
  end
end

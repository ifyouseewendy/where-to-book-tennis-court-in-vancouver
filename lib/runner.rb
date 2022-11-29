require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require_relative './venues'
require_relative './btc_scraper'

class Runner
  # registry contains a mapping between venue and scaper
  # eg.
  #
  # Runner.new(
  #   btc: BTCScraper.new,
  #   ubc: UBCScraper.new,
  # )
  def initialize(registry = {})
    @registry = registry
  end

  def run
    vacancies = []
    @registry.each do |_venue, scraper|
      vacancies << scraper.run
    end
    vacancies
  end
end

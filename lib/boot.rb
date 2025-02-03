require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'json'
require 'pry-byebug'
require 'mechanize'
require 'tzinfo'
require 'bugsnag'
require 'selenium-webdriver'
require 'net/http'

Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_API_KEY']
end

require 'runner'
require 'venues'
require 'vacancy'
require 'vacancies'
require 'btc_scraper'
require 'coq_scraper'
require 'rmd_hub_scraper'
require 'surrey_ttc_scraper'
require 'langley_ttc_scraper'
require 'van_ubc_scraper'
require 'north_van_tc_scraper'

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
    vacancies_by_venue = {}
    @registry.each do |venue, scraper|
      vacancies = scraper.run.to_a
    rescue StandardError => e
      Bugsnag.notify(e)
      vacancies_by_venue[venue] = { errored: true }
    else
      group_by_date = Hash.new { |h, k| h[k] = [] }
      vacancies.each do |vacancy|
        group_by_date[vacancy[:date]] << vacancy
      end

      vacancies_by_venue[venue] = group_by_date
    end
    vacancies_by_venue
  end
end

class Vacancies
  def initialize(vacancies = [])
    @vacancies = vacancies
  end

  def concat(vacancies)
    @vacancies += vacancies
  end

  def sort_and_combine
    combine_court_info(@vacancies.sort).map(&:as_json)
  end

  def to_a
    @vacancies.sort.map(&:as_json)
  end

  private

  # convert
  #
  # [
  #   {:venue=>:coq, :date=>"Mon Dec 05, 2022", :start_time=>"08:00 AM", :end_time=>"08:30 AM", :duration=>"0.5h", :court_info=>"Court 2"},
  #   {:venue=>:coq, :date=>"Mon Dec 05, 2022", :start_time=>"08:00 AM", :end_time=>"08:30 AM", :duration=>"0.5h", :court_info=>"Court 4"}
  #   ...
  # ]
  #
  # into
  #
  # [
  #   {:venue=>:coq, :date=>"Mon Dec 05, 2022", :start_time=>"08:00 AM", :end_time=>"08:30 AM", :duration=>"0.5h", :court_info=>"Court 2, 4"},
  #   ...
  # ]
  def combine_court_info(vacancies)
    combined_vacancies = []
    i = 0
    while i < vacancies.length
      courts = []
      cur_vacancy = vacancies[i]
      while i + 1 < vacancies.length && equal_except_court(vacancies[i], vacancies[i + 1])
        courts << vacancies[i].court_info
        i += 1
      end

      if courts.empty?
        court_info = parse_court_name(vacancies[i].court_info).join(' ')

        combined_vacancies << if court_info == vacancies[i].court_info
                                vacancies[i]
                              else
                                h = vacancies[i].to_h.merge(court_info:)
                                Vacancy.new(**h)
                              end
      else
        courts << vacancies[i].court_info if i < vacancies.length

        combined_vacancy = Vacancy.new(
          venue: cur_vacancy.venue,
          date: cur_vacancy.date,
          start_time: cur_vacancy.start_time,
          end_time: cur_vacancy.end_time,
          duration: cur_vacancy.duration,
          court_info: combine_court_names(courts)
        )
        combined_vacancies << combined_vacancy
      end

      i += 1
    end
    combined_vacancies
  end

  def combine_court_names(courts)
    return '' if courts.empty?

    court = courts[0]
    name, = parse_court_name(court)

    numbers = courts.map do |court|
      _, number = parse_court_name(court)
      number
    end.sort.join(', ')

    "#{name} #{numbers}"
  end

  def equal_except_court(v1, v2)
    v1.to_h.except(:court_info) == v2.to_h.except(:court_info)
  end

  # Indoor Court 1 => ["Indoor Court", 1]
  # Court 01 => ["Court", 1]
  def parse_court_name(court)
    matched = court.match(/(?<name>\D+)(?<number>\d+)/)
    return [court] if matched.nil?

    [matched[:name].strip, matched[:number].to_i]
  end
end

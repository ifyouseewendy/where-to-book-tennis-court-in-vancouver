class Vacancies
  def initialize(vacancies = [])
    @vacancies = vacancies
  end

  def concat(vacancies)
    @vacancies += vacancies
  end

  def sort_and_combine
    combine_court_info(@vacancies.sort).map(&:to_h)
  end

  def to_a
    @vacancies.sort.map(&:to_h)
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
  #   {:venue=>:coq, :date=>"Mon Dec 05, 2022", :start_time=>"08:00 AM", :end_time=>"08:30 AM", :duration=>"0.5h", :court_info=>"Court 2, Court 4"},
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
        combined_vacancies << vacancies[i]
      else
        courts << vacancies[i].court_info if i < vacancies.length

        combined_vacancy = Vacancy.new(
          venue: cur_vacancy.venue,
          date: cur_vacancy.date,
          start_time: cur_vacancy.start_time,
          end_time: cur_vacancy.end_time,
          duration: cur_vacancy.duration,
          court_info: courts.sort.join(', ')
        )
        combined_vacancies << combined_vacancy
      end

      i += 1
    end
    combined_vacancies
  end

  def equal_except_court(v1, v2)
    v1.to_h.except(:court_info) == v2.to_h.except(:court_info)
  end
end

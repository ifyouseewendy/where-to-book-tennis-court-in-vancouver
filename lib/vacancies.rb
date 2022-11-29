class Vacancies
  def initialize
    @vacancies = []
  end

  def concat(vacancies)
    @vacancies += vacancies
  end

  def sort!
    @vacancies.sort do |a, b|
      if a.start_time == b.start_time && a.end_time == b.end_time
        a.court_info <=> b.court_info
      elsif a.start_time == b.start_time
        a.end_time <=> b.end_time
      else
        a.start_time <=> b.start_time
      end
    end
  end

  def to_s
    @vacancies.map(&:to_s).join("\n")
  end
end

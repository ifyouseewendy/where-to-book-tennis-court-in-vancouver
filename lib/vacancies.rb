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

  def to_a
    sort!
    @vacancies
  end

  # {
  #   "2022-11-28": [
  #     "08:00 - 09:00 AM Court 1, Court 2",
  #     "08:00 - 10:00 AM Court 1",
  #     "09:00 - 10:00 AM Court 2",
  #     "01:00 - 02:00 PM Court 6",
  #   ],
  #   "2022-11-29": [
  #     "08:00 - 09:00 AM Court 1, Court 2",
  #     "08:00 - 10:00 AM Court 1",
  #     "09:00 - 10:00 AM Court 2",
  #     "01:00 - 02:00 PM Court 6",
  #   ]
  # }
  def to_h
    raise NotImplementedError
  end
end

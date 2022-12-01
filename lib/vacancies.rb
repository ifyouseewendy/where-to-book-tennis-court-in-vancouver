class Vacancies
  def initialize
    @vacancies = []
  end

  def concat(vacancies)
    @vacancies += vacancies
  end

  def count
    @vacancies.count
  end

  def to_a
    @vacancies.sort
  end

  def to_h
    @vacancies.sort.map(&:to_h)
  end
end

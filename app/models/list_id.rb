class ListID
  attr_reader :car

  def initialize(car)
    @car = car
  end

  def name
    car.name
  end

  def id
    [tag, namespace].join('.')
  end

  def to_s
    "#{name} <#{id}>"
  end

  private

  def tag
    name.downcase.split.insert(-1, car.id).join('-')
  end

  def namespace
    Mail::Address.new(ENV.fetch('MAIL_FROM')).domain
  end
end

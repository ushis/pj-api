class MessageID
  attr_reader :car, :records

  def initialize(car, *records)
    @car = car
    @records = records
  end

  def id
    TaggedAddress.new(ENV.fetch('MAIL_FROM')).tap do |address|
      address.local = local
    end.address
  end

  def to_s
    "<#{id}>"
  end

  private

  def local
    [car_id].concat(record_ids).join('/')
  end

  def car_id
    car.name.downcase.split.insert(-1, car.id).join('-')
  end

  def record_ids
    records.reduce([]) do |arr, record|
      arr << record.model_name.singular if !record.is_a?(Comment)
      arr << record.id
    end
  end
end

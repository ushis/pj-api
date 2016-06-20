class ApplicationMetric
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def payload
    event.payload
  end

  def save
    Influx.write(points)
  end

  private

  def points
    data.map do |key, value|
      {
        series: key.to_s,
        values: {value: value},
        tags: tags
      }
    end
  end
end

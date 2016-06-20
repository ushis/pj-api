class Influx
  class << self

    def write(points)
      client.write_points(points)
    end

    private

    def client
      @client ||= InfluxDB::Client.new(ENV.fetch('INFLUXDB_DB'), {
        host: ENV.fetch('INFLUXDB_HOST'),
        port: ENV.fetch('INFLUXDB_PORT', 8086),
        username: ENV.fetch('INFLUXDB_USER'),
        password: ENV.fetch('INFLUXDB_PASSWORD'),
        async: true
      })
    end
  end
end

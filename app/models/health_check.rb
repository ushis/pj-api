class HealthCheck
  class Component
    attr_reader :error

    def initialize
      call
    rescue StandardError => e
      @error = e.message
    end

    def healthy?
      @error.nil?
    end
  end

  class Database < Component
    def name
      :database
    end

    def call
      ActiveRecord::Migrator.current_version
    end
  end

  attr_reader :components

  def initialize
    @components = [Database.new]
  end

  def healthy?
    components.all?(&:healthy?)
  end
end

class ApplicationJob < ActiveJob::Base
  queue_as :detach
end

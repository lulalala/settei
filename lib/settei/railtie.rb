module Settei
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/settei_tasks.rake"
    end
  end
end
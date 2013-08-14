module Stressque
  class Railtie < Rails::Railtie
    config.after_initialize do
      if ENV['STRESSQUE']
        require 'stressque'
        harness = Stressque::DSL.eval_file(ENV['STRESSQUE'])
        harness.freeze_classes!
      end
    end
  end
end

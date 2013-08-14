module Stressque
  class Railtie < Rails::Railtie
    config.before_configuration do
      if ENV['STRESSQUE'] == 'enabled'
        raise "No JOBS_DIR specified" unless ENV['JOBS_DIR']
        raise "No DSL specified" unless ENV['DSL']

        require 'stressque'
        ENV['JOBS_DIR'].split(File::PATH_SEPARATOR).each do |dir|
          Dir.glob(File.join(dir, '*.rb')) do |rb_file|
            load rb_file
          end
        end

        harness = Stressque::DSL.eval_file(ENV['DSL'])
        harness.freeze_classes!
      end
    end
  end
end

require 'yaml'
require 'ostruct'
require 'pathname'

module TaskManager
  class Config
    attr_reader :config
    def initialize(config_path = File.expand_path('~/.config/task-manager.yml'))
      @config_path = config_path
    end

    def config
      return @config if @config
      data = YAML.load_file(@config_path)
      data['commands'] ||= Array.new
      @config = OpenStruct.new(data)
    end

    def root
      Pathname.new(self.config.root || '~/tasks')
    end

    def commands
      self.config.commands || Array.new
    end
  end
end

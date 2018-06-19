require_relative 'parser'
require_relative 'config'

module TaskManager
  class Task
    STATUS = {
      unstarted: ['-'],
      started: ['-'],
      done: %w{✓ ✔},
      failed: %w{✕ ✖ ✗ ✘}
    }

    def self.parser
      @parser ||= TaskParser.new
    end

    def self.transformer
      @transformer ||= TaskTransformer.new
    end

    def self.process(nvim, &block)
      task = self.parse(nvim.current.line)
      block.call(task, Config.new)
      nvim.current.line = task.to_s
    end

    def self.parse(line)
      tree = self.parser.parse(line)
      self.transformer.apply(tree)
    end

    def initialize(**data)
      @data = data
      @data[:tags] ||= Array.new
      @data[:done_at] ||= '????'
    end

    def tags
      @data[:tags]
    end

    def start!
      @data[:status] = :started
      @data[:started_at] = Hour.now
    end

    def done!
      @data[:status] = :done
      if @data[:started_at]
        @data[:done_at] = Hour.now
      end
    end

    def to_s
      interval = "[%{started_at}-%{done_at}]" % @data if @data[:started_at]
      status_symbol = STATUS[@data[:status]].first
      (["#{[status_symbol, interval].compact.join(' ')} %{body}" % @data] | @data[:tags].map { |tag| "##{tag}" }).join(' ')
    end
  end
end

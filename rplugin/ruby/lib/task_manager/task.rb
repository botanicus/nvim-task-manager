require_relative 'parser'

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
      block.call(task)
      nvim.current.line = task.to_s
    end

    def self.parse(line)
      tree = self.parser.parse(line)
      self.transformer.apply(tree)
    end

    def initialize(**data)
      @data = data
      @data[:tags] ||= Array.new
    end

    def start!
      @data[:status] = :started
      @data[:start_time] = Hour.now
    end

    def done!
      @data[:status] = :done
      if @data[:start_time]
        @data[:end_time] = Hour.now
      end
    end

    def to_s
      interval = "[%{start_time}-%{end_time}]" % @data if @data[:start_time]
      status_symbol = STATUS[@data[:status]].first
      (["#{[status_symbol, interval].compact.join(' ')} %{body}" % @data] | @data[:tags].map { |tag| "##{tag}" }).join(' ')
    end
  end
end

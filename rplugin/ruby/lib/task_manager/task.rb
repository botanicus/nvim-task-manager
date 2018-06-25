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
    end

    def status
      if @data[:status_symbol] == '-' && @data[:started_at]
        return :started
      end

      STATUS.find do |status_name, status_symbols|
        status_symbols.include?(@data[:status_symbol])
      end.first
    end

    def status=(status_name)
      @data[:status_symbol] = STATUS[status_name].first
    end

    def body
      @data[:body]
    end

    def tags
      @data[:tags]
    end

    def start!
      self.status = :started
      @data[:started_at] = Hour.now(s: false)
      @data[:done_at] = '????'
    end

    def unstarted?
      self.status == :unstarted
    end

    def started?
      self.status == :started
    end

    def done?
      self.status == :done
    end

    def done!
      self.status = :done
      if @data[:started_at]
        @data[:done_at] = Hour.now(s: false)
      end
    end

    def to_s
      interval = "[%{started_at}-%{done_at}]" % @data if @data[:started_at]
      (["#{[@data[:status_symbol], interval].compact.join(' ')} %{body}" % @data] | @data[:tags].map { |tag| "##{tag}" }).join(' ')
    end
  end
end

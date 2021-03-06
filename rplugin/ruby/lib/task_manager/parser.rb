require 'parslet'
require 'hour'

module TaskManager
  class TaskParser < Parslet::Parser
    rule(:status_symbol) do
      (match['-✓✔✕✖✗✘'].as(:str) >> str(' ')).as(:status_symbol)
    end

    rule(:hour_strict) do
      (match['\d'].repeat(1) >> str(':') >> match['\d'].repeat(2, 2)).as(:hour)
    end

    rule(:start_time) do
      str('[') >> hour_strict.as(:start_time) >> str(']') >> str(' ').maybe
    end

    rule(:time_frame) do
      # TODO: (hour_strict.absent? >> match['^\]\n'] >> any)
      str('[') >> match['\w '].repeat.as(:str) >> str(']') >> str(' ').maybe
    end

    rule(:header) do
      # match['^\n'].repeat # This makes it hang!
      (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    end

    rule(:task_body) do
      (match['#\n'].absent? >> any).repeat.as(:str)
    end

    rule(:tag) do
      str('#') >> match['^\s'].repeat.as(:str) >> str(' ').maybe
    end

    rule(:started_at) do
      hour_strict.as(:started_at)
    end

    rule(:done_at) do
      (hour_strict | str('????')).as(:str).as(:done_at)
    end

    rule(:from_to) do
      str('[') >> started_at >> str('-') >> done_at >> str('] ')
    end

    rule(:task) do
      (status_symbol >> time_frame.as(:time_frame).maybe >> from_to.maybe >> start_time.maybe >> task_body.as(:body) >> tag.as(:tag).repeat.as(:tags).maybe).as(:task) >> str("\n").repeat
    end

    root(:task)
  end

  class TaskTransformer < Parslet::Transform
    rule(str: simple(:slice)) { slice.to_s.strip }

    rule(tag: simple(:slice)) { slice.to_sym }

    rule(hour: simple(:hour_string)) do
      Hour.parse(hour_string.to_s, s: false)
    end

    rule(status_symbol: simple(:status_symbol)) do
      TaskManager::Task::STATUS.determine_status(status_symbol.to_s)
    end

    rule(task: subtree(:data)) do
      TaskManager::Task.new(**data)
    end
  end
end

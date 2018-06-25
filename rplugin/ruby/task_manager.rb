require_relative './lib/task_manager/task'

module Debug
  def p(*args)
    self.command("echom '#{args.inspect}'")
  end
end

# https://github.com/alexgenco/neovim-ruby
Neovim.plugin do |plugin|
  plugin.command(:TaskManager, sync: true) do |nvim|
    config = TaskManager::Config.new
    nvim.command("cd #{config.root}")
    nvim.command("edit #{Time.now.strftime('%Y/%W')}.todo")
    line = nvim.current.buffer.lines.to_a.find do |line|
      line.match(/^#{Time.now.strftime('%A')}$/)
    end
    line_number = nvim.current.buffer.lines.to_a.index(line) + 1
    nvim.command(":#{line_number}")
    nvim.command(":execute 'normal! zt'")

    line = nvim.current.buffer.lines.to_a.find do |line|
      line.match(/^- /)
    end
    line_number = nvim.current.buffer.lines.to_a.index(line) + 1
    nvim.command(":#{line_number}")
  end

  # Mapped to `<leader>i`.
  plugin.command(:CycleTasksAndInbox) do |nvim|
    case File.basename(nvim.current.buffer.name)
    when 'tasks.todo'
      nvim.command("w | edit #{Time.now.strftime('%Y/%W')}.todo")
    else
      nvim.command("w | edit tasks.todo")
    end
  end

  # Mapped to `<leader>j`.
  plugin.command(:CycleTasksAndJournal) do |nvim|
    if File.basename(nvim.current.buffer.name) == 'tasks.todo'
      nvim.command("w | edit #{Time.now.strftime('%Y/%W')}.notes")
    elsif nvim.current.buffer.name.match?(%r{/\d{4}/\d{2}\.(todo|notes)$})
      # This is always the corresponding todo/journal, not the current week's one.
      current_type = nvim.current.buffer.name.split('.').last
      year_month_path = nvim.current.buffer.name.split('/')[-2..-1].join('/')
      transition_to_type = {todo: 'notes', notes: 'todo'}[current_type.to_sym]
      path = year_month_path.sub(".#{current_type}", ".#{transition_to_type}")
      nvim.extend(Debug).p("#{year_month_path}.sub(\".#{current_type}\", \".#{transition_to_type}\")")
      nvim.extend(Debug).p(nvim.current.buffer.name, path)
      nvim.command("w | edit #{path}")
    end
  end

  # Mapped to `<leader>d`.
  plugin.command(:MarkTaskAsDone) do |nvim|
    TaskManager::Task.process(nvim) do |task, config|
      task.done!
    end

    nvim.command("w | execute 'normal! j'")
  end

  plugin.command(:ParseTask) do |nvim|
    task = TaskManager::Task.parse(nvim.current.line)
    nvim.command("echo '#{task.inspect}'")
  end

  # Mapped to `<leader>s`.
  # Starts the active (where the cursor is) OR the next task?
  plugin.command(:StartTask) do |nvim|
    TaskManager::Task.process(nvim) do |task, config|
      task.start!

      commands = config.commands.transform_keys(&:to_sym)
      if tag = task.tags.find { |tag| commands.include?(tag) }
        # I don't know how to find out when the process has ended when running in :terminal.
        # nvim.command("w | terminal #{commands[tag]}") if tag
        nvim.command("!#{commands[tag]}") if tag
        task.done!
      end
    end
    nvim.command("w")
  end

  # Define an autocmd for the BufEnter event on Ruby files.
  # http://vimdoc.sourceforge.net/htmldoc/autocmd.html
  plugin.autocmd(:BufEnter, pattern: "*.todo") do |nvim|
    nvim.command("echom 'Help: \i: inbox \j: journal'")
  end
end

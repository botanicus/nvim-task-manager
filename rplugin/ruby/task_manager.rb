require_relative './lib/task_manager/task'

# https://github.com/alexgenco/neovim-ruby
Neovim.plugin do |plugin|
  plugin.command(:TaskManager) do |nvim|
    config = TaskManager::Config.new
    nvim.command("cd #{config.root}")
    nvim.command("edit tasks.todo")
  end

  # Mapped to `<leader>c`.
  plugin.command(:TaskManagerCycle) do |nvim|
    case File.basename(nvim.current.buffer.name)
    when 'tasks.todo'
      nvim.command("w | edit #{Time.now.strftime('%Y/%W')}.todo")
    when /^\d+\.todo$/
      nvim.command("w | edit #{Time.now.strftime('%Y/%W')}.notes")
    else
      nvim.command("w | edit tasks.todo")
    end
  end

  # Mapped to `<leader>j`.
  plugin.command(:CycleTasksAndJournal) do |nvim|
    if File.basename(nvim.current.buffer.name) == 'tasks.todo'
      nvim.command("w | edit #{Time.now.strftime('%Y/%W')}.notes")
    elsif (x = nvim.current.buffer.name.split('/')[-3..-1].join('/')).match(/^\d{4}\/\d{2}\.(todo|notes)$/)
      type = Regexp.last_match(1)
      type_2 = {todo: 'notes', notes: 'todo'}[type]
      nvim.command("w | edit #{x.sub(/\.#{type}$/, ".#{type_2}")}")
    end
  end

  # Mapped to `<leader>d`.
  plugin.command(:MarkTaskAsDone) do |nvim|
    TaskManager::Task.process(nvim) do |task, config|
      task.done!
    end

    nvim.command("execute 'normal! j'")
  end

  plugin.command(:ParseTask) do |nvim|
    task = TaskManager::Task.parse(nvim.current.line)
    nvim.command("echo '#{task.inspect}'")
  end

  # Mapped to `<leader>s`.
  # Starts the active (where the cursor is) OR the next task?
  plugin.command(:StartTask, sync: true) do |nvim|
    TaskManager::Task.process(nvim) do |task, config|
      task.start!

      commands = config.commands.transform_keys(&:to_sym)
      if tag = task.tags.find { |tag| commands.include?(tag) }
        nvim.command("terminal #{commands[tag]}") if tag
        task.done!
      end
    end
  end

  # Define an autocmd for the BufEnter event on Ruby files.
  # http://vimdoc.sourceforge.net/htmldoc/autocmd.html
  plugin.autocmd(:BufEnter, pattern: "*.todo") do |nvim|
    # TODO: Go to the next unstarted task.
    nvim.command("echom 'Activating task integration.'")
  end
end

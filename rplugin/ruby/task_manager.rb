require_relative './lib/task_manager/task'

# TODO: Make it available only for *.todo files.
# https://github.com/alexgenco/neovim-ruby
Neovim.plugin do |plugin|
  plugin.command(:TaskManager) do |nvim|
    config = TaskManager::Config.new
    nvim.command("cd #{config.root}")
    nvim.command("edit tasks.todo")
  end

  # Mapped to `<leader>c`.
  plugin.command(:TaskManagerCycle) do |nvim|
    if File.basename(nvim.current.buffer.name) == 'tasks.todo'
      nvim.command("w | edit #{Time.now.strftime('%Y/%W')}.todo")
    else
      nvim.command("w | edit tasks.todo")
    end
  end

  # Mapped to `<leader>d`.
  plugin.command(:MarkTaskAsDone) do |nvim|
    TaskManager::Task.process(nvim, &:done!)
    # nvim.current.pos += nvim.current.pos
  end

  # postpone, nargs: 2 do |nvim, a, b

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

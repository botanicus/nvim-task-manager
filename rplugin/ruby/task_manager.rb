require_relative './lib/task_manager/task'

# https://github.com/alexgenco/neovim-ruby
Neovim.plugin do |plugin|
  # Mapped to `td`.
  plugin.command(:MarkTaskAsDone) do |nvim|
    TaskManager::Task.process(nvim, &:done!)
    # nvim.current.pos += nvim.current.pos
  end

  plugin.command(:ParseTask) do |nvim|
    task = TaskManager::Task.parse(nvim.current.line)
    nvim.command("echo '#{task.inspect}'")
  end

  # Mapped to `ts`.
  # Starts the active (where the cursor is) OR the next task?
  plugin.command(:StartTask) do |nvim|
    TaskManager::Task.process(nvim, &:start!)
  end

  # Define an autocmd for the BufEnter event on Ruby files.
  # http://vimdoc.sourceforge.net/htmldoc/autocmd.html
  plugin.autocmd(:BufEnter, pattern: "*.todo") do |nvim|
    # TODO: Go to the next unstarted task.
    nvim.command("echom 'Activating task integration.'")
  end
end

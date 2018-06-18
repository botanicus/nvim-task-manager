# After updating this file :UpdateRemotePlugins has to be called.
# TODO: enter: \n- , 2x cancel
#
# PlanWeek -> start a new file.

# require "pomodoro/formats/scheduled"
# Pomodoro::Formats::Scheduled.

# https://github.com/alexgenco/neovim-ruby
Neovim.plugin do |plugin|
  # Mapped to `td`.
  plugin.command(:MarkTaskAsDone) do |nvim|
    line = nvim.current.line
    # TODO: Use the parser.
    if line.match(/^- \[\d+:\d+-\?+\] /)
      nvim.current.line = line.sub(/^- \[(\d+:\d+)-\?+\] /, "✓ [\\1-#{Time.now.strftime('%H:%M')}] ")
    else
      nvim.current.line = line.sub(/^- /, '✓ ')
    end
    # nvim.current.pos += nvim.current.pos
  end

  # Mapped to `ts`.
  # Starts the active (where the cursor is) OR the next task?
  plugin.command(:StartTask) do |nvim|
    nvim.current.line = nvim.current.line.sub(/^- /, "- [#{Time.now.strftime('%H:%M')}-????] ")
  end

  # Mapped to `ta`.
  # plugin.command(:ActiveTask)

  #plugin.commmand(:ArchiveTasks)

  # Define an autocmd for the BufEnter event on Ruby files.
  # http://vimdoc.sourceforge.net/htmldoc/autocmd.html
  plugin.autocmd(:BufEnter, pattern: "*.todo") do |nvim|
    # TODO: Go to the next unstarted task.
    nvim.command("echom 'Activating task integration.'")
  end

  plugin.command(:ReloadTaskPlugin) do |nvim|
    lines = File.readlines(__FILE__)[10..-2]
    instance_eval(lines.join)
    nvim.command("echom 'Reloading the task plugin.'")
  end
end

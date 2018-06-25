# About

Manage your task list without ever leaving Vim.

# Usage

`vim +TaskManager`

## File hierarchy

### Top-level `tasks.todo`

This is your GTD inbox and contexts.

```
Blog
- Import old articles.
- Fix deployment.

Prague
- Catch up with Vaclav.

24/12
- [9:20] Skype with Jaime.

# This is essencially GTD inbox.
Later
- ...
```

### Per-week task file `YYYY/%WW.todo`

Personally I found weeks the easiest unit to work with.
I found planning for a longer periods of time than just a day highly beneficial.

And since a month is a long time and _I'll do it tomorrow_ is a thing, I found weeks most easily manageable. It's still good to plan for longer periods of time than just a week, but this file is meant as an _execution plan_.

This file works as an archive at the same time.

```
# Objectives:
# - Deploy the new blog.
# - ...

Monday
- Headspace. #meditation
- [10:15] Yoga.
```

#### Format extension

While the `tasks.todo` format supports only one task per line, the per-week files can carry metadata. Otherwise the format is exactly the same.

```
- Find out how to reload NeoVim plugins.
  Resolution: Currently unsupported.
```

- `Postponed: reason`
- `Postponed to: date`
- `Waiting for: event`

### Per-week expense file `YYYY/%WW.expenses`

The expense file is to be a valid YAML file.

```yaml
Monday:
- Expense 1: 10 EUR
- Expense 2: 30 USD

Tuesday:
# ...
```

## Configuration

```yaml
root: ~/Dropbox/Data/Tasks
commands:
  hs: headspace play
  lf: lifeflow play
```

## Scripts

`bin/expenses`

# TODO

- find ~/Dropbox/Data/Tasks | grep '\.todo$' | ruby -ne 'puts File.read($_.chomp).scan(/#[^\s]+/).flatten.uniq' | sort -ru
- UltiSnips. (In user space: tag completion, template (how to do schedules?))
- `:TaskManager`: only search in today. This might grant extending the parser: `task_groups[today].find(&:unstarted).line_number`
- `:TaskReset`
- Instead of cycle, use \w -> week, \j -> journal, \i -> inbox (but allow them to cycle).
- `postpone, nargs: 2 do |nvim, a, b|`
- Make it available only for *.todo files.
- Support start_time (9:20).
- Parser: support started_at-done_at.
- NextWeek, PrevWeek.
- Format: show metadata of finished tasks as comments as well.
- Postponing should create a new task in tasks.todo.
- Launch scheduler to show notifications.
- Write the doc.
- TODO: enter: \n- , 2x cancel

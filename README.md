# About

Manage your task list without ever leaving Vim.

_This is a very minimalistic plugin and the README documents how I use it more so than anything else._

## File hierarchy

### Top-level `tasks.todo`

This is your GTD inbox and contexts.

```
Blog
- Import old articles
- Fix deployment

Prague
- Catch up with Vaclav

24/12
- [9:20] Skype with Jaime

# This is essencially GTD inbox.
Later
- ...
```

### Per-week task file `YYYY/%WW.todo`

Personally I found weeks the easiest
I found planning for a longer periods of time than just a day highly beneficial.

And since a month is a long time and _I'll do it tomorrow_ is a thing, I found weeks most easily manageable. It's still good to plan for longer periods of time than just a week, but this file is meant as an _execution plan_.

This file works as an archive at the same time.

```
# Objectives:
# - Deploy the new blog
# - ...

Monday
- Headspace #meditation
- [10:15] Yoga
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

# TODO

- Format: show metadata of finished tasks as comments as well.
- Switching between tasks.todo and a per-week file.
- Support named commands.
- Postponing should create a new task in tasks.todo.
- Launch scheduler to show notifications.
- Write the doc.

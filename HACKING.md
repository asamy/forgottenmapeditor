# Hacking ForgottenMapEditor

We really appreciate people who would like to help build FME further.

If you would like to do so, please read this guide on how to format your code
to fit with the current code base.

## For VIM Users

If you're a VIM user, and that type who like to change his tabwidth, spaces -> tabs everytime,
then we strongly recommend VIM's modeline feature;

At end of every file you edit, write:
```lua
-- vim: set ts=2 sw=2 et:
```

## Code Style

### Nested if-cases

Instead of doing:

```
if something and otherthing and anotherthing and onemorething and anotherthing then
    ...
end
```

please, do:

```
if something and otherthing and anotherthing and onemorething
     and morethings then
    ...
end
```

TL;DR: Try to limit your line width a little to make it more readable.

### Avoid one-liners

Instead of doing:
```
if not something then return end
```

Use:
```
if not something then
  return
end
```

### Avoid braces in if-cases

Do not:
```
if (something) then
```

### Use appropriate names for variables

Do not:
```
local p = item:getId()
```

Instead, use:
```
local itemId = item:getId()
```

It's fine to use:
```
local i = 0
...
i = i + 1
```

in a loop.

Comment code you feel is confusing.

## Commits

Try to avoid nesting commits together, e.g.:

You fixed a bug where you have an item that does not appear, when cycling through code
you found a code style bug, ignore it, make a commit for the fix then fix the code style
and make another commit.


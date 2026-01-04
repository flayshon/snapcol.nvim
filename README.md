# snapcol.nvim

A Neovim plugin that snaps the cursor to column 0 when moving vertically, except for the last line that had horizontal movement.

Designed to be:
- buffer-local
- Kickstart.nvim–friendly
- Lazy.nvim–ready

---

## How it works

- `j` / `k` always move to **absolute column 0**
- Horizontal movement (`h`, `l`, `w`, `$`, mouse clicks, searches, jumps, etc.) updates internal cursor column memory for that line.
- Optional restriction to specific filetypes
- Toggle per buffer with `:SnapColToggle`

---

## Motivation

When reading or scanning code top-to-bottom, it’s often more useful for vertical movement to:

- align to the start of the line
- avoid inheriting arbitrary cursor columns
- behave consistently across lines

`snapcol.nvim` enforces that rule without breaking normal horizontal navigation.

---

## Installation (Lazy.nvim)

```lua
{
  'flayshon/snapcol.nvim',
  opts = {
    -- optional
  },
}
```

## Usage

### Default behavior

- auto-enables for all normal, local buffers
- Special buffers (help, prompt, etc.) are ignored
- You can toggle it per buffer at any time with `:SnapColToggle`


### Restrict SnapCol to specific filetypes

If you only want it for certain languages:

```lua
opts = {
  filetypes = { 'go', 'lua', 'python', 'rust', 'typescript' },
}
```

With this configuration, other buffers behave normally unless toggled manually.

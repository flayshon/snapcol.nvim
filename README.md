# snapcol.nvim

A Neovim plugin that snaps the cursor to column 0 when moving vertically, except for the last line that had horizontal movement.

Designed to be:
- buffer-local
- Kickstart.nvim–friendly
- Lazy.nvim–ready

---

## How it works

- `j` / `k` / `gg` / `G` always move to **absolute column 0**
- Horizontal movement (`h`, `l`, `w`, `$`, mouse clicks, searches, jumps, etc.) updates internal cursor column memory for that line. Only the last line with horizontal movement is stored at a time.
- Toggle per buffer with `:SnapColToggle`

---

## Motivation

When reading or scanning code top-to-bottom, I find it more useful for vertical movement to:

- align to the start of the line
- avoid inheriting arbitrary cursor columns
- behave consistently across lines visually

---

## Installation (Lazy.nvim)

```lua
{
  'flayshon/snapcol.nvim',
  opts = {
    filetypes = nil -- auto enables for every filetype
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

![mini](./.examples/muVim_mini.png)

<div align="center">
  <p>
    <a href="https://github.com/AndresMpa/mu-nvim">
      <img
        src="https://img.shields.io/badge/-vim-darkgreen?style=for-the-badge&logo=Vim"
        alt="VimScript"
      />
    </a>
    <a href="https://github.com/AndresMpa/mu-nvim">
      <img
        src="https://img.shields.io/badge/-bash-black?style=for-the-badge&logo=GNU%20Bash"
        alt="Bash Script"
      />
    </a>
  </p>
</div>

# Mini

A single `init.vim` for Vim and Neovim. It is the first MμVim config, kept as a template and for machines where a Lua plugin manager is more trouble than it is worth.

There is a walkthrough at [andresmpa.github.io/mu-vim-page](https://andresmpa.github.io/mu-vim-page/).

If you want modules, use [VimScript](https://github.com/AndresMpa/mu-vim-vimscript). If you want the current Neovim stack, use [Current](https://github.com/AndresMpa/mu-vim).

## Screenshots

![Welcome](./.examples/nvim_0.png)
![Welcome](./.examples/nvim_1.png)
![Welcome](./.examples/nvim_2.png)
![Welcome](./.examples/nvim_3.png)

## How to read it

The file is split into "slides": comment banners of `"` characters. Open `init.vim` and jump between those headers. That is the whole table of contents.

## Quick start

```
git clone https://github.com/AndresMpa/mu-vim-mini.git
cd mu-vim-mini
./install.sh
nvim
```

Then:

```
<Space> p i
:source %
:CocInstall
```

On Windows, clone into `%LOCALAPPDATA%\nvim` and run Plug / CoC by hand.

The installer uses [pnpm](https://pnpm.io/installation), not npm.

A [cheat sheet](https://github.com/AndresMpa/mu-vim-mini/blob/main/CheatSheet.md) covers native motions.

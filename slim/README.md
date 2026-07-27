# Slim shell base

A small, friendly starting point for anyone who lives in the terminal but has
never set up a shell config. It's a curated slice of a much larger personal
[dotfiles setup](../README.md) — just the broadly useful parts, with none of
the machinery that only makes sense for one person's machine.

**No magic.** It won't clone repositories in the background, install packages,
or take over your shell. It's one file you `source`. Delete one line to undo it.

Works with **bash** and **zsh** — pick the file that matches your shell.

---

## What you get

Out of the box, with zero extra installs:

- **Reachable history** — type the start of a command and press <kbd>↑</kbd> to
  cycle through just the matching past commands.
- **A case-insensitive completion menu** — <kbd>Tab</kbd> through matches; `foo`
  finds `Foo`.
- **A clean, git-aware prompt** — shows your directory and current branch.
- **Sensible history** — bigger, de-duplicated, shared between open shells.
- **A handful of aliases** you'll actually use (`gs`, `ll`, `..`, `mkcd`,
  `extract`, and friends).

Install a few small tools and it lights up further (all optional):

- **[`fzf`](https://github.com/junegunn/fzf)** → <kbd>Ctrl</kbd>+<kbd>R</kbd>
  opens a **live, searchable menu of your command history**, plus
  <kbd>Ctrl</kbd>+<kbd>T</kbd> (files) and <kbd>Alt</kbd>+<kbd>C</kbd> (cd).
- **[`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions)**
  (zsh) or **[`ble.sh`](https://github.com/akinomyoga/ble.sh)** (bash) → grey
  **"ghost text"** predicting your command from history as you type.
- **[`zoxide`](https://github.com/ajeetdsouza/zoxide)** → `z <partial-name>` to
  jump to directories you visit often.
- **[`eza`](https://github.com/eza-community/eza)** / **[`bat`](https://github.com/sharkdp/bat)**
  → prettier `ls` and `cat`.

Run **`slimhelp`** at any time to see what's active and what to install next.

---

## Install

### The quick way

From this folder:

```sh
./install.sh          # auto-detects bash or zsh from your $SHELL
```

That adds a single guarded line to your `~/.bashrc` or `~/.zshrc` (and, on
macOS, makes sure `~/.bash_profile` loads your `~/.bashrc`). Re-running is safe.

Then open a new terminal — or reload the current one:

```sh
exec $SHELL
```

### The manual way (if you'd rather see exactly what changes)

You only ever add **one line**. Point it at whichever file matches your shell.

**bash** — add to the end of `~/.bashrc`:

```bash
[ -r "/path/to/slim/base.bash" ] && . "/path/to/slim/base.bash"
```

> On macOS, new Terminal windows are *login* shells and read `~/.bash_profile`
> instead of `~/.bashrc`. If you don't already have a `~/.bash_profile`, create
> one with this line so your `~/.bashrc` actually loads:
> ```bash
> [ -r ~/.bashrc ] && . ~/.bashrc
> ```

**zsh** — add to the end of `~/.zshrc`:

```zsh
[ -r "/path/to/slim/base.zsh" ] && . "/path/to/slim/base.zsh"
```

Replace `/path/to/slim` with wherever you saved this folder. Reload with
`exec $SHELL` and you're done.

### Don't have this folder locally?

Grab just the one file for your shell. For example, with `curl`:

```sh
mkdir -p ~/.config/slim
curl -fsSL <raw-url-to>/base.bash -o ~/.config/slim/base.bash   # or base.zsh
```

Then add the matching `source` line above, pointing at
`~/.config/slim/base.bash`.

---

## Unlocking the optional tools

Install as many or as few as you like — the base adapts to whatever is present.

**macOS** (with [Homebrew](https://brew.sh)):

```sh
brew install fzf zoxide eza bat
brew install zsh-autosuggestions        # zsh users, for ghost text
```

**Debian / Ubuntu:**

```sh
sudo apt install fzf zoxide eza bat
sudo apt install zsh-autosuggestions    # zsh users, for ghost text
```

**bash ghost text** uses [`ble.sh`](https://github.com/akinomyoga/ble.sh),
which also adds syntax highlighting. One-time setup:

```sh
git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh ~/.local/share/blesh-src
make -C ~/.local/share/blesh-src install PREFIX=~/.local
```

Open a new shell after installing anything, then run `slimhelp` to confirm.

---

## Making it your own

- **Add your own aliases and functions:** put them *after* the `source` line in
  your `~/.bashrc` / `~/.zshrc`. Anything there wins.
- **Don't like an alias?** `unalias name` after the source line, or just
  override it with your own definition.
- **Want the prompt gone?** Set your own `PS1`/`PROMPT` after the source line.

## Uninstalling

Delete the `# >>> slim base >>>` … `# <<< slim base <<<` block from your
`~/.bashrc` / `~/.zshrc` (and `~/.bash_profile` if present), or just remove the
single `source` line you added manually. Nothing else was touched.

---

## FAQ

**Is this going to slow down my shell?** No. It's a single small file with no
network calls; optional integrations only run if the tool is installed.

**Will it change how my commands behave?** It's intentionally conservative. It
doesn't enable spelling autocorrect prompts, doesn't block `>` overwrites, and
doesn't replace `cd`. The riskiest thing it does is make `ls`/`cat` prettier
*when* `eza`/`bat` are installed.

**Can I see the full setup this came from?** Yes — the
[parent dotfiles repo](../README.md) has the complete, zsh-first configuration
(themed prompt, more tools, terminal configs, and a bootstrap installer). This
slim base is the "just the good bits" version meant to be easy to adopt.

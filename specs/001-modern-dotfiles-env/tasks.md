# Tasks: Modern Dotfiles Environment

**Input**: Design documents from `specs/001-modern-dotfiles-env/`
**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅

**Tests**: Not explicitly requested — no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and
testing of each increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the repository directory skeleton required by all phases.

- [x] T001 Create dotfiles directory structure: `zsh/`, `zsh/aliases/`, `tmux/`, `starship/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shell entry-point and stubs that every subsequent phase sources or extends.
All modules must exist (even as stubs) before later tasks can append to them.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T002 Write `zsh/.zshrc` module orchestrator: source `path.zsh`, `env.zsh`, `plugins.zsh`, `completions.zsh`, `keybindings.zsh`, `lazy.zsh`, `prompt.zsh`, and all files in `zsh/aliases/` — in that order; add `~/.zshrc.local` and `~/.aliases.local` sourcing at the end if files exist
- [x] T003 [P] Write `zsh/path.zsh` stub: declare `$PATH` block comment headers per domain (system, snap, local bin); add `$HOME/.local/bin` and `/snap/bin` entries
- [x] T004 [P] Write `zsh/env.zsh` stub: declare `export` block with `BAT_THEME`, `EDITOR`, `VISUAL`, and `PAGER` headers (values populated in later phases)

**Checkpoint**: Shell entry-point exists and sources empty module files without error — `zsh .zshrc` must exit cleanly.

---

## Phase 3: User Story 1 — Fresh Machine Bootstrap (Priority: P1) 🎯 MVP

**Goal**: A developer runs `bash install.sh` on a fresh Ubuntu machine and gets a fully
functional shell environment in under 15 minutes.

**Independent Test**: Run `install.sh` on a clean Ubuntu 22.04 image; open a new Zsh
session; confirm all required tools respond to `--version`; confirm symlinks in `$HOME`
point into the repo; confirm startup benchmark ≤200ms.

### Implementation for User Story 1

- [x] T005 [US1] Write `install.sh` header and argument parsing: `--dry-run`, `--yes`, `--skip-packages` flags per `contracts/install-script.md`; emit colored `[OK]` / `[SKIP]` / `[WARN]` / `[ERROR]` / `[SNAP]` / `[ACTION REQUIRED]` prefixes
- [x] T006 [US1] Add package installation loop to `install.sh`: iterate declared package list; attempt `apt-get install -y <pkg>`; on failure emit `[SNAP]` and attempt `snap install <pkg>`; on snap failure emit `[WARN]` and add to post-install summary
- [x] T007 [US1] Add snap availability guard to `install.sh`: check `snapd` is running before any snap fallback; print one-time warning and skip all snap installs for the run if unavailable
- [x] T008 [US1] Add symlink creation logic to `install.sh`: for each managed dotfile in the canonical list (`contracts/install-script.md`), check if target exists; if target is already the correct symlink print `[SKIP]`; if target exists and is not a symlink prompt user (`[dotfiles] ~/.file already exists. Overwrite? [y/N]:`); on confirm remove and symlink; on decline print `[SKIP]` and continue
- [x] T009 [US1] Add Oh My Zsh install step to `install.sh`: check if `~/.oh-my-zsh` exists; if not, clone Oh My Zsh repository into `~/.oh-my-zsh`; print `[OK]` or `[SKIP]`
- [x] T010 [US1] Add post-install summary to `install.sh`: collect all failed and `[ACTION REQUIRED]` items; print them at the end of the run; exit with code 0 even if some steps were skipped
- [x] T011 [US1] Write `zsh/plugins.zsh`: set `ZSH` to `$HOME/.oh-my-zsh`; declare `plugins=(git zsh-autosuggestions zsh-syntax-highlighting)`; source `$ZSH/oh-my-zsh.sh`
- [x] T012 [US1] Write `zsh/completions.zsh`: call `autoload -Uz compinit` and `compinit`; set `zstyle` options for case-insensitive matching and menu completion
- [x] T013 [US1] Write `zsh/keybindings.zsh` base bindings: set `bindkey -e` (emacs mode); bind Home/End/Delete keys; leave fzf keybinding slots as comments (populated in US3)
- [x] T014 [US1] Write `zsh/lazy.zsh`: add self-replacing lazy load shims for `nvm`, `pyenv`, and `rbenv` — each shim unsetting itself and sourcing the real init on first invocation
- [x] T015 [US1] Write `zsh/prompt.zsh` base: add `eval "$(starship init zsh)"` guarded by `command -v starship`; leave zoxide slot as a comment (populated in US3)
- [x] T016 [US1] Update `zsh/path.zsh` with tool-specific `$PATH` entries: `$HOME/go/bin`, `/usr/local/go/bin`, `$HOME/.cargo/bin` as conditional appends (only if directory exists)
- [x] T017 [US1] Run `install.sh --dry-run` and confirm output matches contract; then run full install on the environment and verify all symlinks resolve, all packages present, shell opens without errors
- [x] T018 [US1] Benchmark `time zsh -i -c exit` five times; if any run exceeds 200ms, profile with `zsh -i -c "zprof; exit"` and move offending init into `zsh/lazy.zsh`

**Checkpoint**: User Story 1 fully functional — `bash install.sh` installs and configures the
environment; new Zsh session opens cleanly; startup ≤200ms.

---

## Phase 4: User Story 2 — Tmux Multiplexed Workflow (Priority: P2)

**Goal**: A developer opens tmux and gets a keyboard-driven multiplexer with a Catppuccin
Mocha themed status bar, named sessions, split panes, and detach/reattach.

**Independent Test**: Open tmux; create 2 windows and 3 split panes; rename the session;
detach; reattach; verify status bar shows session name, window list, hostname, and time —
all in Catppuccin Mocha colors; verify no mouse required for any action.

### Implementation for User Story 2

- [x] T019 [P] [US2] Write `starship/starship.toml`: set `add_newline = false`; configure prompt modules (directory, git_branch, git_status, cmd_duration, character) using Catppuccin Mocha hex values from `data-model.md` theme table
- [x] T020 [P] [US2] Update `zsh/plugins.zsh`: add `ZSH_HIGHLIGHT_STYLES` map entries using Catppuccin Mocha hex codes for `command`, `unknown-token`, `path`, `globbing`, `single-quoted-argument`, `double-quoted-argument`
- [x] T021 [P] [US2] Update `zsh/env.zsh`: set `export BAT_THEME="Catppuccin-mocha"`; set `export EDITOR=nvim` (fallback `vim` if nvim absent); set `export PAGER=bat`
- [x] T022 [US2] Write `tmux/.tmux.conf`: set prefix to `Ctrl+a`; bind `|` to split-window horizontal; bind `-` to split-window vertical; bind `h`/`l` for window navigation; bind `hjkl` for pane navigation; set `mouse off`; bind `<prefix>+m` to toggle mouse; set `default-terminal "screen-256color"`; set `terminal-overrides "xterm-256color:Tc"` for true color
- [x] T023 [US2] Add TPM plugin declarations to `tmux/.tmux.conf`: `set -g @plugin 'tmux-plugins/tpm'`; `set -g @plugin 'tmux-plugins/tmux-sensible'`; `set -g @plugin 'catppuccin/tmux'`; set `@catppuccin_flavor 'mocha'`; configure status bar to show session, windows, host, time; add `run '~/.tmux/plugins/tpm/tpm'` at end of file
- [x] T024 [US2] Add TPM bootstrap step to `install.sh`: after Oh My Zsh install, check if `~/.tmux/plugins/tpm` exists; if not, clone TPM repository; print `[OK]` / `[SKIP]`; print `[ACTION REQUIRED]` notice to press `<prefix>+I` in tmux to install plugins
- [x] T025 [US2] Add `tmux/.tmux.conf` to managed symlinks list in `install.sh` (target: `~/.tmux.conf`); add `starship/starship.toml` to managed symlinks list (target: `~/.config/starship.toml`); create `~/.config/` if not present
- [ ] T026 [US2] Live tmux test: open tmux session; create 2 windows, 3 split panes; rename session; detach with `<prefix>+d`; reattach with `tmux attach`; verify status bar renders Catppuccin theme with correct fields; verify all pane/window operations work without mouse

**Checkpoint**: User Story 2 fully functional — tmux opens with Catppuccin Mocha theme;
all keyboard operations work; sessions persist across detach/reattach.

---

## Phase 5: User Story 3 — Zsh Productivity Environment (Priority: P3)

**Goal**: A developer types partial commands and gets inline suggestions, navigates with
smart jumps, uses concise aliases for frequent operations, and sees live syntax highlighting
— all in a shell that starts in ≤200ms.

**Independent Test**: Open a fresh Zsh session; type 3 chars of a prior command and confirm
inline suggestion appears; press Tab after a partial path and confirm completions list; type a
known alias and confirm it executes correctly; type an invalid command and confirm it shows
in error color; type `z dot` and confirm navigation to `~/dotfiles`.

### Implementation for User Story 3

- [x] T027 [US3] Write `zsh/aliases/aliases-git.zsh`: define `gs`→`git status`, `gd`→`git diff`, `gco`→`git checkout`, `gst`→`git stash`, `glog`→`git log --oneline --graph`, `gpush`→`git push`, `gpull`→`git pull`, `gaa`→`git add -A`, `gcm`→`git commit -m`, `gb`→`git branch`, `gbd`→`git branch -d`, `grb`→`git rebase`, `gcp`→`git cherry-pick`, `gsh`→`git show`, `gbl`→`git blame` — include `# g* prefix` domain header comment
- [x] T028 [P] [US3] Write `zsh/aliases/aliases-system.zsh`: `ll`→`eza -la --icons` (comment: `# original: \ls`), `la`→`eza -a --icons`, `l`→`eza --icons`, `df`→`df -h`, `du`→`du -sh`, `free`→`free -h`, `psg`→`ps aux | grep`, `mkd`→`mkdir -p` — guard eza aliases with `command -v eza` check, fallback to `ls -la`
- [x] T029 [P] [US3] Write `zsh/aliases/aliases-nav.zsh`: `..`→`cd ..`, `...`→`cd ../..`, `....`→`cd ../../..`, `~`→`cd $HOME`, `dl`→`cd ~/Downloads`, `dt`→`cd ~/Desktop`, `dot`→`cd ~/dotfiles`
- [x] T030 [P] [US3] Write `zsh/aliases/aliases-docker.zsh`: `dps`→`docker ps`, `dpsa`→`docker ps -a`, `dex`→`docker exec -it`, `drm`→`docker rm`, `dri`→`docker rmi`, `dlog`→`docker logs -f`, `dstop`→`docker stop`, `dprune`→`docker system prune -f` — include `# d* prefix` domain header comment
- [x] T031 [P] [US3] Write `zsh/aliases/aliases-editor.zsh`: `vim`→`nvim` (comment: `# original: \vim`), `v`→`nvim`, `e`→`$EDITOR` — guard with `command -v nvim` check
- [x] T032 [US3] Update `zsh/.zshrc` orchestrator: add `for f in "$ZDOTDIR/aliases/"aliases-*.zsh; do source "$f"; done` loop after `plugins.zsh` sourcing; source `~/.aliases.local` if it exists
- [x] T033 [US3] Update `zsh/keybindings.zsh`: add fzf shell integration — source fzf keybindings file (`/usr/share/doc/fzf/examples/key-bindings.zsh` or `$(brew --prefix)/opt/fzf/shell/...`); bind `Ctrl+R` for fuzzy history, `Ctrl+T` for fuzzy file insert, `Alt+C` for fuzzy `cd`; guard with `command -v fzf`
- [x] T034 [US3] Update `zsh/prompt.zsh`: add `eval "$(zoxide init zsh)"` after Starship init; guard with `command -v zoxide`
- [ ] T035 [US3] Smoke test all alias domains: open fresh Zsh session; run `type gs` → must show git status alias; run `type ll` → must show eza alias; run `type dps` → must show docker ps alias; run `type vim` → must show nvim alias; run `z dot` → must navigate to `~/dotfiles`; run `Ctrl+R` → fzf history widget must open

**Checkpoint**: User Story 3 fully functional — inline suggestions, syntax highlighting, all
alias domains, fzf keybindings, and zoxide all work in a fresh shell session.

---

## Phase 6: User Story 4 — Documentation and Discoverability (Priority: P4)

**Goal**: A developer unfamiliar with the dotfiles reads the README and can install the
environment and correctly use any tool or alias without consulting external resources.

**Independent Test**: Hand the README to a peer unfamiliar with the setup; they must
successfully install the environment and use three tools (one from tmux, one alias domain,
one zsh feature) using only the README.

### Implementation for User Story 4

- [x] T036 [US4] Write `README.md` Quick Start section per `data-model.md` README entity: prerequisites (Ubuntu 22.04+, sudo, internet, Nerd Font), clone command, `bash install.sh`, `chsh -s $(which zsh)`, open new terminal, open tmux + press `<prefix>+I`, verify benchmark
- [x] T037 [P] [US4] Write `README.md` What's Installed table: one row per required tool (zsh, Oh My Zsh, Starship, fzf, zoxide, zsh-autosuggestions, zsh-syntax-highlighting, tmux, TPM, catppuccin-tmux, bat, eza, jq, neovim optional) — columns: Tool | Purpose | Key Command
- [x] T038 [P] [US4] Write `README.md` Alias Reference: one table per domain mirroring exact aliases from `zsh/aliases/*.zsh` — columns: Alias | Expansion | Use Case; sections: Git Aliases, System Aliases, Navigation Aliases, Docker Aliases, Editor Aliases
- [x] T039 [US4] Write `README.md` Tmux Cheatsheet table: list every key binding from `tmux/.tmux.conf` — columns: Keys | Action; sections: Prefix, Panes, Windows, Sessions, Mouse
- [x] T040 [P] [US4] Write `README.md` Zsh Features section: inline autosuggestions (accept with `→`), syntax highlighting (green/red), fzf (`Ctrl+R` history, `Ctrl+T` file, `Alt+C` cd), zoxide (`z <partial>`, `zi` interactive)
- [x] T041 [P] [US4] Write `README.md` Customization section: explain `~/.zshrc.local` (sourced last by `.zshrc`) and `~/.aliases.local` (sourced after all alias files); show example content; note both are gitignored and never overwritten by install script
- [x] T042 [P] [US4] Write `README.md` Platform Notes section: WSL2 font setup in Windows Terminal settings; clipboard with `xsel`/`xclip` or `win32yank`; note 200ms benchmark is measured inside WSL2 not from Windows host

**Checkpoint**: User Story 4 fully functional — README reviewed by a peer who installs the
environment and uses three tools correctly without external help.

---

## Phase 7: Polish & Quality Gates

**Purpose**: Verify all constitution gates pass; harden the environment against regressions.

- [x] T043 [P] Constitution gate — Performance: run `time zsh -i -c exit` 10 consecutive times; all runs MUST be ≤200ms; if any exceed threshold run `zsh -i -c "zprof; exit"` to identify culprit and move to `zsh/lazy.zsh`
- [ ] T044 Constitution gate — Idempotency: run `install.sh` on an already-configured machine; confirm second run emits only `[SKIP]` lines for all existing correct symlinks; confirm no packages are reinstalled; confirm exit code 0
- [x] T045 [P] Constitution gate — Alias conflict check: verify no name in any `zsh/aliases/*.zsh` file appears in the forbidden list from `contracts/alias-naming.md` (`cd`, `pwd`, `export`, `source`, `.`, `eval`, `exec`, `exit`, `kill`, `sudo`, `su`) or collides with required tool names
- [x] T046 [P] Constitution gate — Cross-section isolation: for each file in `zsh/*.zsh`, comment it out individually and run `zsh --no-rcs -c "source zsh/.zshrc; exit"` on the remaining files; confirm no remaining module errors
- [ ] T047 Constitution gate — Interactive smoke test: open a brand new Zsh terminal session; verify: prompt renders in Catppuccin Mocha colors, typing `git` partial shows autosuggestion, typing `gti` shows red error highlight, `z dot` navigates to `~/dotfiles`, `Ctrl+R` opens fzf history widget, `tmux` opens with themed status bar
- [ ] T048 Constitution gate — Peer usability: provide README to one developer unfamiliar with the dotfiles; record whether they successfully install and use 3 tools without external help; update README if any step causes confusion

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 Bootstrap (Phase 3)**: Depends on Foundational — delivers MVP
- **US2 Tmux (Phase 4)**: Depends on Foundational; T019/T020/T021 can start after T011 (plugins.zsh exists); T022–T026 can start after T002 (directory structure exists)
- **US3 Productivity (Phase 5)**: Depends on Foundational; T027–T031 can start after T001 (aliases/ directory exists); T033 depends on T013; T034 depends on T015
- **US4 Documentation (Phase 6)**: Depends on US1, US2, US3 all complete (documents the final state)
- **Polish (Phase 7)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Depends on Phase 2 only — no dependency on other stories
- **US2 (P2)**: Depends on Phase 2; shares `zsh/plugins.zsh` (T020 appends to T011's output) and `zsh/env.zsh` (T021 appends to T004's output) — coordinate edits to those files
- **US3 (P3)**: Depends on Phase 2; T033 extends T013 (`keybindings.zsh`); T034 extends T015 (`prompt.zsh`) — coordinate
- **US4 (P4)**: Depends on US1 + US2 + US3 all complete (README documents the finished environment)

### Within Each User Story

- Models/config files before the tasks that reference them
- `install.sh` symlink list must be updated in the same phase that introduces each new dotfile
- Smoke/benchmark tests always last in their phase

### Parallel Opportunities

- T003 and T004 are fully parallel (different files, both in Phase 2)
- T005–T010 in US1 are largely parallel except T006 depends on T005 (install.sh structure) and T010 depends on T009
- T019, T020, T021 in US2 are fully parallel (different files)
- T027, T028, T029, T030, T031 in US3 are fully parallel (one file each)
- T037, T038, T040, T041, T042 in US4 are fully parallel (README sections)
- T043, T045, T046 in Phase 7 are fully parallel

---

## Parallel Example: User Story 1 (Bootstrap)

```
# These can run simultaneously (different files):
T005  install.sh header/args
T011  zsh/plugins.zsh
T012  zsh/completions.zsh
T013  zsh/keybindings.zsh
T014  zsh/lazy.zsh
T015  zsh/prompt.zsh

# Then sequentially:
T006  install.sh snap fallback        (extends T005)
T007  install.sh snapd guard          (extends T005)
T008  install.sh symlink logic        (extends T005)
T009  install.sh Oh My Zsh step       (extends T005)
T010  install.sh post-install summary (extends T005)
T016  zsh/path.zsh tool entries       (extends T003)
T017  dry-run + full install test     (depends on T005–T010, T011–T015)
T018  startup benchmark               (depends on T017)
```

## Parallel Example: User Story 3 (Productivity)

```
# These can run simultaneously (one file each):
T027  zsh/aliases/aliases-git.zsh
T028  zsh/aliases/aliases-system.zsh
T029  zsh/aliases/aliases-nav.zsh
T030  zsh/aliases/aliases-docker.zsh
T031  zsh/aliases/aliases-editor.zsh

# Then:
T032  update .zshrc to source all alias files  (depends on T027–T031 existing)
T033  add fzf keybindings to keybindings.zsh   (parallel with T032)
T034  add zoxide to prompt.zsh                 (parallel with T032)
T035  smoke test all domains                   (depends on T032–T034)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 — Setup (T001)
2. Complete Phase 2 — Foundational (T002–T004)
3. Complete Phase 3 — US1 Bootstrap (T005–T018)
4. **STOP and VALIDATE**: run `install.sh` on clean Ubuntu; confirm all required tools
   install; confirm Zsh opens with prompt; confirm startup ≤200ms
5. Ship/demo: the environment is installable and functional even without the full theme,
   aliases, or README

### Incremental Delivery

1. Setup + Foundational → directory structure and shell entry-point exist
2. US1 complete → installable, bootstrapped, functional Zsh (demo-able MVP)
3. US2 complete → Catppuccin theme across shell + tmux; multiplexed workflow
4. US3 complete → full alias registry, fzf, zoxide — daily productivity ready
5. US4 complete → README enables any developer to adopt the environment
6. Polish → all constitution gates pass; environment is production-ready

### Notes

- Commit after each numbered task or after a logical group within a phase
- Stop at each **Checkpoint** to validate the story independently before proceeding
- Any `install.sh` edit that adds a new dotfile MUST also add the symlink entry in the same task
- When two tasks edit the same file (e.g., `zsh/plugins.zsh` in T011 and T020), the second task appends — it does not rewrite the whole file
- `[P]` tasks in the same phase touching the same file are not parallel — only mark `[P]` when files are distinct

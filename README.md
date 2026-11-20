# curd

A small terminal code editor written in Rust with `crossterm`: open a folder as a project, browse it in a file tree with git status colours, keep several files open in tabs, and get colours, errors, suggestions, hover and go-to-definition from language servers. It has undo, selection with copy and cut, search and replace in the file and across the project, markers beside the lines you changed since the last commit, and a git menu to stage, commit, switch and create branches, pull and push, a panel that runs your build and tests and jumps to the errors, and a panel where Claude (on your own Claude subscription) reads, changes and builds the project.


## Install

One command. It downloads the latest release for your system.

Linux and macOS:

```sh
curl -fsSL https://raw.githubusercontent.com/vikram5258/curd/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/vikram5258/curd/main/install.ps1 | iex
```

Then:

```sh
curd .               # open the current folder as a project
curd src/main.rs     # open one file (or several: they open in tabs)
curd                 # start with an empty file
```

To install by hand, download a binary from the [releases page](https://github.com/vikram5258/curd/releases)

**Updating.** Inside curd, F1 and then `Update curd`: the install command above runs in the background over the copy of curd that is running, while you go on working, and when it is done curd opens again by itself in the same folder with the same files, nothing to press. If files have unsaved changes, or Claude is in the middle of an answer, it waits for that first and the status bar says so. When curd starts it asks GitHub once whether a newer release is out and, if there is, says so in the status bar and keeps a button there, `update to v…`, until you take it; `CURD_UPDATES=off` turns that off, and then nothing in curd touches the network but what you ask of it. The copy that is running is moved aside while the new one is put in its place (`curd.old`, removed at the next start).

## Command line

```sh
curd                      an empty file to start typing in
curd file.rs              a file (or several: curd a.rs b.rs, each in a tab)
curd src/main.rs:42       the file with the cursor on line 42
curd src/main.rs:42:9     line 42, column 9 (what a compiler or grep prints)
curd +42 file.rs          the same, the way vim takes it (+ alone is the last line)
curd .                    a folder as a project, with its file tree
some-command | curd       the output of a pipe, as a buffer to edit
curd -                    the same, said plainly
curd --version            which version this is, and for which machine
curd --help               a short version of this
```

Paths that do not exist yet are made on the first save. A file whose name
really contains a colon is taken whole, so `curd a:b` opens `a:b` if that
file is there. A buffer read from a pipe has no file of its own; save it
with the save key and it asks where to put it.

**Settings are environment variables**, so you can put `export CURD_…` in
your shell profile to keep one:

| Variable | What it does |
|---|---|
| `CURD_THEME` | `dark`, `light` or `classic`; without it, the terminal's own background decides (see Look) |
| `CURD_LSP` | `off` turns language servers off; a command string uses a different server (see Language servers) |
| `CURD_AGENT` | `off` turns the Claude panel off; a command string runs that in place of the assistant's program |
| `CURD_ASK` | `off` starts the Claude panel in "may change files" instead of "asks first" |
| `CURD_NOTIFY` | `off` stops the panel putting up a desktop notification when you are in another window |
| `CURD_KEYS` | `off` leaves the terminal unasked what keys it can tell apart (so no Shift+Enter; a touch faster to start) |
| `CURD_UPDATES` | `off` stops curd asking GitHub at the start whether a newer release is out |
| `CURD_HINTS` | `off` starts without the status bar's buttons |
| `CURD_TABS` | `auto` shows the tab bar only for two files or more |
| `CURD_BLAME` | `off` stops showing which commit last changed each line |

## Look

`curd` has three looks, called themes:

- **dark** (the usual one) and **light** paint the whole window in colours of their own: the text, the file tree, the panels and the pop-up lists each have their own background; the line the cursor is on is gently lit; selected text and the picked row of a list have a soft background instead of harsh reversed colours; the tab in front and the title of the panel that has the keys stand out; code is coloured by kind, with comments in italics.
- **classic** uses only your terminal's own sixteen colours and its background, as `curd` always did.

Lists that pop up (quick open, the list of commands, the git menu) are a filled box in the middle of the top of the text, with a reminder of the keys on the row you type on. The lists of the Claude panel (`/`, `@`, the models, the earlier conversations) open in the panel itself, right above the question, where you are typing and looking. In the file tree the file in front stays marked in bold while the keys are elsewhere.

The status bar is also the toolbar. Between the file's name and the position it has buttons for what can be done right now, each showing its key: click one, or press the key. They change with where you are and how things stand: **save** while there are unsaved changes, **copy** while text is selected, **commits** (every commit and the graph of the branches) in a git repository, **changes** when the file differs from the last commit, **run** or **run again**; in the file tree **open**, **new file**, **new folder**, **rename**, **delete**; in an assistant's panel **send** (or **stop** while it answers), **mode**, **commands**; in the history **open commit**. As many are shown as fit, the likeliest first, and F1 has everything. "Show or hide the status bar's buttons" in the list of commands turns them off and on, and `CURD_HINTS=off curd` starts without them.

The tab bar is there with one file open as with several, so the text does not move down a row when a second file is opened, and the one file has its `×` to close it. A window under twelve rows keeps that row for the text, and `CURD_TABS=auto curd` shows the bar only for two files or more.

When the terminal says it can show any colour (most do: it sets `COLORTERM=truecolor`), curd asks it for its background and starts light on a light one and dark on a dark one (dark where it does not say). Otherwise you get classic. To choose: `CURD_THEME=light curd`, `CURD_THEME=dark curd` or `CURD_THEME=classic curd` (put `export CURD_THEME=light` in your shell profile to keep it).

## Keys

Project and files:

| Key | What it does |
|---|---|
| F1 or Alt+X | the list of commands: every command with its keys, in groups (File, Tree, Edit, Find, Code, Run, Git, Claude, Look). Type part of a name or a group, Enter does it |
| F1 twice, or Alt+? | every keyboard shortcut on one page, to read through |
| Ctrl+P or Alt+P | quick open: type part of a file name, Enter opens it, Esc cancels |
| Ctrl+B or Alt+B | show or hide the file tree |
| Alt+E | move between the file tree and the text (Esc also leaves the tree) |
| Arrows, Enter (in the tree) | move; Enter or Right opens a folder or file, Left closes a folder |
| n / f (in the tree) | new file / new folder, in the selected folder (`a/b/c.rs` makes the folders on the way) |
| r or F2 (in the tree) | rename the selected file or folder; open files follow |
| d or Delete (in the tree) | delete the selected file or folder, on the second press |
| Ctrl+T | run a command in the project: a build, the tests, the program |
| F5 | run the last command again |
| Alt+T | show what the command printed and move there; pressed again there, hide it |
| F8 / Shift+F8 | go to the next / previous place (file and line) the command's output names |
| Alt+. and Alt+, | next / previous tab (Ctrl+PageDown / Ctrl+PageUp also work) |
| Alt+1 ... Alt+9 | go to that tab |
| Ctrl+W or Alt+W | close the file in front (asks for a second press if it has unsaved changes) |
| Ctrl+L or Alt+L | go to a line by its number |
| Alt+S | search the whole project: type the text, Enter lists the matching lines, Enter again opens one |
| Ctrl+G or Alt+V | git menu: stage, unstage, commit, switch or create a branch, pull, push, fetch, show changes |
| F4 / Shift+F4 | what changed since the last commit: in this file / in the whole project. Enter on a line goes to it in its file |
| F6 / F7 / F9 | fetch / pull / push |
| Alt+Y, or the **commits** button in the status bar | history: the graph of every commit on every branch. Enter on a commit opens it |
| F10, or a click on the branch's name | list the branches, to switch to one |
| Alt+I | the Claude panel: show it and type there; pressed again there, hide it |
| Ctrl+S | save; a file with no name yet asks for one first |
| Ctrl+Q | quit (asks for a second press if any file has unsaved changes) |

Editing:

| Key | What it does |
|---|---|
| Typing, Enter, Tab | insert text, a new line, four spaces |
| Backspace / Delete | delete before / under the cursor (joins lines at a line edge) |
| Arrows, Home, End | move the cursor; the view scrolls in both directions |
| PageUp / PageDown | move one screen up / down |
| Ctrl+Home / Ctrl+End | go to the start / end of the file |
| Shift+arrows, Shift+Home / End / PageUp / PageDown | select text |
| Ctrl+A | select everything |
| Ctrl+C / Ctrl+X | copy / cut the selection, or the whole line when nothing is selected |
| Ctrl+V | paste what was copied or cut |
| Tab / Shift+Tab (with lines selected) | move the selected lines one level in / out; Shift+Tab alone moves the cursor line out |
| Alt+C or Ctrl+/ | turn the cursor line or the selected lines into comments, and back |
| Alt+Up / Alt+Down | move the cursor line up / down |
| Alt+D | duplicate the cursor line |
| Ctrl+Z / Ctrl+Y | undo / redo |
| Ctrl+F or Alt+F | search: type to find, Enter or Down for the next match, Up for the one before, Esc to close |
| F3 or Alt+N | next match of the last search |
| Ctrl+R or Alt+R | replace: type what to find, Enter, type what to put there; then Enter replaces one match, Alt+A all, Down skips one |
| Ctrl+Space or Alt+/ | ask the language server for suggestions (they also appear by themselves as you type) |
| Up / Down, Tab, Esc (in the list of suggestions) | pick one, put it in, close the list |
| Alt+K or Ctrl+K | fold / unfold the block on, or around, the cursor line |
| Alt+A | fold every top-level block, or unfold everything |
| Alt+H or F2 | hover: show what the language server knows about the thing under the cursor |
| Alt+G or F12 | go to definition, opening the file it is in if needed |
| Tab after a trigger word | expand a snippet (see below) |

Mouse:

| Action | What it does |
|---|---|
| Click a tab / its `×` | bring that file to the front / close it (a second click if it has unsaved changes) |
| Middle click a tab | close it |
| Wheel over the tab bar | go through the tabs |
| Click a file or folder in the tree | open it / open or close the folder |
| Click in the text | put the cursor there |
| Double click in the text | select the word |
| Drag over the text | select |
| Click beside a line that starts a block (the `-` or `+` by its number) | fold or unfold the block |
| Click a line in quick open, the git menu or search results | pick it; the wheel moves the selection, a click elsewhere closes the list |
| Wheel | scroll whatever is under the pointer |

Because `curd` listens to the mouse, selecting with the terminal itself needs Shift held while dragging (Option on macOS Terminal).

Some terminals keep certain Ctrl keys for themselves (VS Code's terminal takes Ctrl+K, Ctrl+B, Ctrl+P, Ctrl+W and Ctrl+F), which is why most commands also have an Alt or function-key form.

You do not have to learn the tables below: **F1** lists every command with its keys and runs the one you pick, and **F1 again** (or Alt+?) shows all the shortcuts on one page, with how lists and the mouse work. Both are made from one list inside the program, so neither can miss a command. The list also offers things that have no key of their own: each line of the git menu, and switching between the dark, light and classic looks while the editor runs.

## Projects

`curd some-folder` opens the folder as a project. `curd some-file` works out the project from the file: its git repository if it is in one, otherwise the folder it sits in. Ctrl+B shows the tree either way.

- **File tree:** folders first, then files. Folders are read only when you open them, so large projects open instantly. The tree follows the file in front, and is re-read when you save or come back to the terminal window. Drag the line between the tree and the text to make the tree wider or narrower; it keeps room for the text. (The Claude panel beside the text is draggable the same way, and Alt+Up/Down sizes it from the keys.)
- **Git status colours**, with a letter at the right edge of the tree, the same idea as VS Code:

| Colour | Letter | Meaning |
|---|---|---|
| plain | | committed and unchanged |
| yellow | `M` | modified since the last commit, not staged |
| cyan | `S` | staged with `git add`, waiting to be committed |
| green | `U` | untracked: a new file git does not know yet |
| red | `!` | merge conflict |
| dim | | ignored by `.gitignore` |

  A folder takes the colour of the most pressing change inside it. The current branch is shown under the tree. The status comes from the `git` command, run in the background so it never holds up typing.
- **Change markers beside the text:** in a file that git tracks, a bar next to the line numbers shows what is different from the last commit, and it follows every key, saved or not:

| Marker | Meaning |
|---|---|
| green `▎` | a new line |
| yellow `▎` | a changed line |
| red `▁` | lines were removed below this line (`▔` at the top of the file: removed above it) |

- **Many tabs:** when there are more tabs than fit, the tab bar moves along so that the one in front is always in view, behind a ` < ` that says there are more before it. Having many files open costs nothing while you type: what is done for every open file (asking git about it, checking whether another program changed it) is done only when something could have changed.
- **Tabs:** every open file keeps its own cursor, folds and unsaved changes. The tab bar appears when two or more files are open; a `●` marks unsaved changes and a click on the `×` closes the tab.
- **Quick open (Ctrl+P):** searches every file git tracks or would track (so not `target/` or `node_modules/`). Letters can be spread out: `wsrs` finds `workspace.rs`.

## Language servers (LSP)

`curd` gets colours, errors, warnings, suggestions, hover and go-to-definition from the same language servers VS Code and other editors use. It starts the server for the file's type, if it is installed. One server looks after all the open files of its language in a project, so opening more files does not start more servers:

| Language | Server | Install |
|---|---|---|
| Rust | `rust-analyzer` | `rustup component add rust-analyzer` |
| Python | `pyright-langserver` | `npm install -g pyright` |
| JavaScript / TypeScript | `typescript-language-server` | `npm install -g typescript typescript-language-server` |
| C / C++ | `clangd` | your system's `clangd` package |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` |
| YAML (`.yaml`, `.yml`) | `yaml-language-server` | `npm install -g yaml-language-server` |

- **Colours:** come from two places, as in VS Code. A small built-in scanner colours keywords, strings, comments and numbers the instant a file opens and on every key, with or without a server. The server then says what each piece of code really is (function, type, macro and so on) and its colours are laid over the scanner's a moment later. In the classic look they are your terminal's own sixteen colours, so they match your terminal theme; the dark and light looks bring their own. YAML has a scanner of its own: keys, quoted and plain values, numbers and words like `true`, comments, anchors, tags, `${{ ... }}` expressions, and blocks of text after `|` or `>`.
- **Underlines:** the exact code an error or warning is about is underlined. Unused code is shown faded and deprecated code struck through.
- **Suggestions (completion):** a list opens under the cursor when you start a word or type `.` or `::`, and narrows as you keep typing. Up and Down pick one, Tab puts it in, Esc closes the list. Enter always starts a new line, so the list never gets in the way of plain typing. Ctrl+Space (or Alt+/) asks for the list by hand.
- Lines with a problem get a red `E` or yellow `W` beside the line number; move the cursor onto the line to read the message in the status bar. The status bar also shows a count, like `E:1 W:2`.
- Without a server installed, `curd` works as a plain editor and says so once in the status bar.
- `CURD_LSP=off curd file.rs` turns servers off. `CURD_LSP="my-server --stdio" curd file.rs` uses a different one.

How it works: `curd` runs the server as a child process and talks to it over stdin/stdout. Edits are sent as small changes (not the whole file), batched while you type, and a background thread reads the answers, so typing never waits on the server.

## Running commands

Ctrl+T asks for a command (`cargo build`, `npm test`, `python app.py`, anything your shell runs) and runs it in the project folder. What it prints appears in a panel under the text as it comes, with errors in red and warnings in yellow, and the title says whether it is still running, finished or failed. F5 runs the same command again, which is the usual loop: change the code, F5, look.

- **Going to errors:** lines that name a place in a file, the way compilers and test runners print them (`src/main.rs:12:5`, `--> src/lib.rs:3:1`, `File "app.py", line 4`), can be jumped to. F8 goes to the first, then the next; Shift+F8 goes back. In the panel (Alt+T), Enter or a click on such a line does the same.
- **In the panel:** arrows, PageUp / PageDown, Home / End and the wheel move through the output; Ctrl+C stops the command; Esc goes back to the text.
- The command cannot be typed to while it runs: it is for builds and tests. For a program that asks questions, start the command with `!` (as in `! python3 -i`): `curd` steps aside and gives it the whole terminal, and Enter brings the editor back when it has ended.
- When the command ends, the file tree, the git state and open files that it changed are brought up to date.

## Claude panel

Alt+I opens a panel where you can ask Claude about the project, or ask it to change it. It works with your Claude subscription (Pro or Max), the way the VS Code extension does: `curd` runs the `claude` command you have installed and signed in to, in the project folder, and shows what it answers. `curd` itself never sees your login and uses no API key.

The panel works with the mouse as well as the keys. Under the question is a row of buttons: **send** (**stop** while it answers, **sign in** when you are not signed in), what it may do (**read only**, **edits**, **edits + commands**: each click goes to the next), the **model**, **@ file** to attach one, **/ commands**, **history** for the earlier conversations and **+ new** for a fresh one. After an answer that changed files, **undo** takes the changes back and **2 changed** opens the files. 

**Looking over what it changed.** After an answer that changed files, they are listed above the question, each with how many lines were put in and taken out and three buttons of its own: **diff** opens what changed in that file (as it was before the answer against as it is now, in a tab, with Enter going to the line in the file), **keep** takes it off the list, and **undo** puts that one file back the way it was and leaves the others. **keep all** and **undo all** in the heading do it for every file. The list is the changes of the last answer: asking the next question keeps what is left. A low panel shows the heading and a button that lists the files.

In the conversation, click a file's name (`src/main.rs`, or `src/main.rs:42` for a line) to open it there; a click elsewhere on the line of a card such as "Edit src/main.rs" opens or closes the card. `CURD_HINTS=off` leaves the buttons out, and a panel under seven rows keeps the row for the conversation.

On a wide terminal (100 columns or more beside the file tree) the panel stands to the right of the text, the full height of the window, like a side bar; on a narrower one it lies under the text.

Set up once: install [Claude Code](https://code.claude.com/docs). Then, in the panel, type `/login`: `curd` steps aside and gives the terminal to Claude's own sign-in (`claude auth login`), which opens Anthropic's sign-in page in your browser for your Claude subscription, as the VS Code extension does. When it is done, Enter brings the editor back. `/account` says who is signed in and on which plan; `/logout` signs out.

### Other assistants

Assistants work the way extensions do in an editor like VS Code: each is its own thing, with a panel of its own. Claude's panel and Cursor's panel are side by side as tabs in the title of the panel. Each keeps its own conversation, its own question being typed, its own model and its own say in what it may do, and each goes on working when you look at another one (its tab is marked with `*` while it works). Nothing is carried over from one to the other.

- **A panel starts with its account.** The first time you open one, it asks the assistant's own program who is signed in, and shows where things stand before anything else: the program is not installed (and how to get it); or you are not signed in, and Enter signs you in; or who you are signed in as, and then what you can ask. Signing in opens the assistant's own sign-in page in your browser and brings you back to the panel when it is done.
- **To go to an assistant's panel:** click its tab; or Alt+Left / Alt+Right in the panel; or F1 and its name (`Cursor: Open its panel`); or `/agent`, which lists them with whether each one's program is installed, and how to get it if not.
- **Each has commands under its own name** in the list of commands (F1): `Claude: Sign in`, `Cursor: Sign in`, `Cursor: Say who is signed in`, and so on.
- **The one you used last** is the one that opens with Alt+I next time (kept in `~/.config/curd/agents.json`).

Three are built in:

| Assistant | Its program | What it uses |
|---|---|---|
| Claude | `claude` ([Claude Code](https://code.claude.com/docs)) | your Claude subscription, after `/login` |
| Cursor | `agent` ([Cursor CLI](https://cursor.com/docs/cli/overview): `curl https://cursor.com/install -fsS \| bash`) | your Cursor account, after `/login` |
| opencode | `opencode` ([opencode.ai](https://opencode.ai)) | whatever providers you set up in it |

`/login`, `/logout` and `/account` in a panel are that assistant's own. Cursor answers the way Claude does (what it reads and runs is listed as it goes); for it, "read only" is its ask mode and "run commands" its `--force`.

Any other program that takes a question on its command line and prints an answer can be added to that file:

```json
{
  "default": "Cursor",
  "agents": {
    "codex": {
      "name": "Codex",
      "command": ["codex", "exec", "{prompt}"],
      "login": ["codex", "login"],
      "install": "npm install -g @openai/codex"
    },
    "gemini": {
      "name": "Gemini",
      "command": ["gemini", "--prompt", "{prompt}"]
    }
  }
}
```

Each assistant is a command and the words to add to it for what the panel offers. Only `command` is needed.

| Key in the file | What it is |
|---|---|
| `name` | what it is called in the panel's title and in `/agent` |
| `command` | the program and its arguments for one question; `{prompt}` is the question |
| `resume` | added to carry on a conversation, for programs that say what theirs is called; `{session}` is that name |
| `continue` | added to carry on the last conversation, for programs that do not |
| `model`, `models` | added to choose a model (`{model}`), and the models `/model` offers |
| `live` | added for a program that reads its questions from its input, one line of JSON each, and stays for the whole conversation, the way `claude --input-format stream-json` does: one process answers all the questions, the next one is written to it, and a question can be given to it while it works. Leave it out for a program that is run once per question |
| `ask` | added for a program that can ask before each thing it changes or runs, the way `claude` does: it prints a request for each thing it wants to do and reads the answer on its input. It needs `live`. Leave it out for a program that cannot |
| `plan` | added for a program that can plan first and put the plan to the user the way it asks (`claude --permission-mode plan`). It needs `live` |
| `read_only`, `edit`, `run` | added for what Alt+M sets: only read; change files; change files and run commands. With none of the three, the program's own settings decide and the panel says so |
| `context` | added to tell it which file is in front and what is selected (`{context}`); without it, that goes in front of the question |
| `format` | `"text"` (the usual): what it prints is the answer. `"claude"`: it prints what `claude --output-format stream-json` prints |
| `login`, `logout`, `status` | its own commands behind `/login`, `/logout` and `/account` |
| `install` | how to get the program, said when it is not installed |

- `"default"` names the one the panel starts with. An entry called `claude`, `cursor` or `opencode` replaces the built-in one.
- Everything else in the panel works with any of them: attaching files, several lines, the list of changed files, and Alt+U to put them back.
- Claude was run for real while building this. Cursor is set up from its documentation and opencode from its `--help`; the two examples above follow those programs' documentation. If one does not work, its `--help` says what the words should be.
- Signing in always happens in the assistant's own program, with the terminal to itself. `curd` never sees a password or a token, and stores none.

| Key (in the panel) | What it does |
|---|---|
| Typing, Enter | write a question and send it; follow-ups carry on the same conversation. While it works, Enter keeps the question for when the answer ends, and Enter on the empty line then sends the kept question at once, into the answer |
| Shift+Enter, Alt+Enter or Ctrl+J | start a new line in the question (pasted text keeps its lines too) |
| Tab | while it works: send what you typed into the answer it is on, now, instead of keeping it for the end |
| / (at the start of the question) | list the panel's commands: `/model`, `/attach`, `/new`, `/resume`, `/mode`, `/undo`, `/changes`, `/copy`, `/bigger`, `/help`, `/hide`, and your own |
| ? (on the empty question) | the page of keyboard shortcuts, with the panel's keys on it |
| @ | pick a file to attach to the question; Backspace on an empty question takes the last one off |
| Left / Right, Home / End, Backspace / Delete | edit the question |
| Up / Down | on the empty question, bring back the questions asked before; in a question of several lines, move between them |
| Ctrl+O | open or close the newest step of the answer (a command, an edit, a search); again on an open command, all of what it printed |
| Ctrl+Up / Ctrl+Down | put the keys on the newest / oldest step: Up and Down then walk the steps, Enter or Space opens and closes one, `o` opens the file it names, `c` or Ctrl+C copies what it printed or changed, Esc goes back to the question (typing does too) |
| End / Home (on the empty question), Ctrl+End / Ctrl+Home | back to the newest line of the conversation / up to its first |
| Esc | leave the step the keys are on; stop the answer Claude is working on, and the conversation goes on from there; otherwise go back to the text (the panel stays) |
| Alt+M or Shift+Tab | what Claude may do: ask before each change or command; plan first; change files; only read; change files and run commands. The title says which; a click on it there goes round too |
| Alt+O | list the files Claude changed in its last answer, to open one |
| Alt+U | undo Claude's changes: put those files back as they were before the answer |
| Ctrl+N | start a new conversation |
| Ctrl+R or Alt+R | list the earlier conversations about this project; Enter shows one again and carries it on |
| PageUp / PageDown, wheel | scroll the conversation; scrolled up, it stays put while new lines come, and `↓ N new` at the bottom (or End) goes back down |
| Alt+Z | make the panel as big as the screen allows, and back |
| Alt+Up / Alt+Down, or drag the panel's edge (its title row, or the line beside it) | make the panel bigger / smaller |
| Alt+C, or Ctrl+C on the question | copy the last answer |
| Alt+I | hide the panel |

- **Before the first question** the panel says who is signed in and offers four questions to start with; a click puts one on the line. The empty question line says what to do with it.
- **Models:** `/model` lists `opus`, `sonnet` and `haiku`, or takes any model's full name; "default" leaves the choice to the `claude` command. The model button under the question shows the model the next question goes to, or the one that last answered.
- **Attached files** are shown on the rule above the question. They are named to Claude along with the question, and it reads them; they go with that one question. Images can be attached the same way.
- **Your own commands:** the `/` list also shows the commands and skills you have set up for Claude Code (in `.claude/commands` and `.claude/skills`, in the project or your home folder). Picking one puts `/name` on the question line, to send to `claude` with whatever you add. A `/name` the list does not know is put on the line the same way.
- **Conversations are kept.** The `claude` command saves every conversation about a project, also the ones from its own terminal program and from VS Code. Ctrl+R lists them, newest first, each with how long ago it was and its first question; picking one shows what was said, with what was done back then as the same cards, and your next question carries it on.
- **A strip above the question** carries what is going on. While Claude works it is the working line: a spinner, the word *Working* with a slow bright sweep over it, how long it has been, the step it is on, and `Esc stops`. When the answer is in, the strip shows what it took: how long, what it cost as the `claude` command reckons it, and a small meter of how much of the model's memory the conversation fills (`6.1s · $0.09 · ▓▓░░░░░░ 20%`). Attached files sit on the strip too, each a chip with an `✗` to take it off.
- **The files it changed** are listed above the question after an answer that changed any: a heading `Changed 2 files` with `keep all` and `undo all`, then each file with how many lines went in and out and its own `diff`, `keep` and `undo`. Click a file's name to open it.
- **The look.** Your own words stand in a tinted block with a bar in the accent colour down its side, and so does the question line; the main button is in the accent too. Answers are set in the text colour, headings in the accent, code on a tinted ground, Claude's thinking faint and slanted behind a thin bar. Each question is set off from the answer before it by a thin rule, and text is kept to a width that reads well however wide the panel is. Before the first question the panel shows its name in block letters. The steps can be walked with Ctrl+Up and Ctrl+Down and opened with Enter; while you read back through a long answer the view holds its place and a `↓ N new` note says what arrived.
- **Each thing it does is a card**: one line that starts with how it stands, a spinner while it runs, then a green ✓ or a red ✗, and says what, with a mark for the kind (`$ cargo test` for a command, `✎ src/main.rs` for an edit, `≡` for a file read, `⌕` for a search, `⚑` for a helper) and how long it took; a chevron at the end where there is more to see. While it works the strip above the question names the step it is on, and the title stays still. Click the line to open the card: a command with the command itself and everything it printed, nothing cut; an edit as it was made, with line numbers, lines put in on a green ground and taken out on a red one; what went wrong, in red. An edit starts open and a command closed, saying how many lines it printed; one that failed opens by itself. Files it read and searches it made that follow one another are folded into one card, open to list them. What it was refused is marked `not allowed`.
- **Its thinking** is shown faint while it thinks, the last few lines of it, and then as how long it took.
- **A helper** (a second assistant Claude sets to work on a part) is a block of its own, open while it works, its line saying what it is doing right now; the helper's steps stand inside it, indented, with its words and its report, and the block folds up when the helper is done. The answer goes on until the helper has reported and Claude has taken that in.
- **Its list of things to do** is one card by the question, kept up to date as it goes: each item with a box, ticked when done, pointed at while being done, and the count in its line.
- **One process for the conversation.** The `claude` command is started once for a conversation and given each question on its input, the way the VS Code extension does, so it keeps what it has read between questions and a follow-up starts at once. A new conversation, another model or another mode starts a new process, which carries the conversation on. Esc stops the answer it is on and keeps the conversation and the process; Esc again ends the process.
- **The next question while it works.** Type it and press Enter: it is kept above the question line as **Next**, to go when the answer ends. Its buttons: **send now** gives it to Claude in the middle of the answer, which takes it into account at once; **change** puts it back on the line (Backspace on the empty line does the same); **drop** forgets it (Delete on the empty line). A second question kept goes under the first.
- The answer appears word by word as Claude writes it, and the title shows how long it has been working.
- Answers are shown as Markdown: headings and `**bold**` in bold, `` `code` `` in colour, list items with a bullet, and blocks of code set apart by a bar and coloured like code in the editor.
- **Attached files** (`@`) are shown above the question, each as a piece of its own ending in `×`: click it to take that file off again, whatever you have typed. Backspace in an empty question takes off the last one, and `/detach` all of them.
- Text selected in the file when you ask is sent along, so you can select a function and ask "what does this do?".

- **Asks first** is how Claude starts: before it changes a file or runs a command it stops and shows, above the question, what it wants to do, with the lines it would take out and put in, or the command. Answer with **y** (yes), **n** or Esc (no: it is told you said no, and says what it wanted instead of trying another way), or **a** (yes, and from now on always for that kind of thing, edits or commands, until a new conversation). The three answers are also buttons. Nothing is changed while it waits. Alt+M, or the mode button, goes on to the other modes below, and `CURD_ASK=off curd` starts in "may change files" as earlier versions did. An assistant that cannot ask (Cursor, opencode) does not have this mode.
- **Plans first** is the mode after it (Alt+M once more): Claude reads and thinks but changes nothing, and puts its plan to you when it is done, as a card in the conversation and a question above the question line: **y** approves it and Claude starts on it, asking before each change as in "asks first"; **r** opens the plan as a page of its own to read; **n** sends it back, and what you type next says what to change.
- **Its own questions.** When Claude has a question for you, with answers to pick from, it is a card above the question line: a number picks an answer (for one that takes several, numbers mark and Enter sends), or type an answer of your own and press Enter; Esc leaves it unanswered and it goes on as it thinks best. This is in "asks first" and "plans first".
- **May change files** is the next mode: Claude can edit and create files in the project. Open files then show what it wrote, the change markers show where, and the panel lists the files it touched. Alt+U puts them all back as they were before that answer (files over 512 KB are not kept for this), which is the way to turn a change down after looking at it. With **read only** (Alt+M) Claude can read and search but its tools for editing files and running commands are switched off. With **may change files and run commands** (Alt+M again) it can also run shell commands in the project without asking, so it can build what it wrote, run the tests and fix what fails. That is the mode for getting real work done, and the one to be careful with: a command can do anything you could do in a terminal, and Alt+U only puts files back.
- Claude is told which file is in front and the line the cursor is on, so "this function" means something. It is told with every question, as part of the question, so it knows where you are now and not where you were when the conversation started. It reads files from disk, so save first.
- If the `ANTHROPIC_API_KEY` variable is set, the `claude` command bills that key instead of your subscription; the panel says so.
- `CURD_AGENT=off curd` turns the panel off. `CURD_AGENT="some-command"` runs that in place of the assistant's program.
- This is not an Anthropic product. Anthropic's terms do not let other programs offer Claude sign-in or handle subscription logins themselves, which is why `curd` only starts the unmodified `claude` program that you signed in to yourself.

## What the terminal itself can do

`curd` uses what a modern terminal (Ghostty, kitty, WezTerm, iTerm2, foot, Windows Terminal, the terminal in VS Code) can do beyond showing text, and does without where one cannot:

- **Every frame in one go** (synchronized output), so a half-drawn screen is never seen.
- **The look follows the terminal's background**: asked for it at the start, curd starts in its light look on a light terminal and its dark look on a dark one. `CURD_THEME` still decides where it is set.
- **Shift+Enter** for a new line in the question, where the terminal tells it from Enter (kitty's keyboard protocol); Alt+Enter everywhere. The panel's hint says which. `CURD_KEYS=off` leaves the terminal unasked.
- **The window title and tab** say what is going on: `curd · project`, and while Claude works, a spinner, its name and the step it is on. Terminals with a progress mark in the tab (Ghostty, kitty, Windows Terminal, VS Code) show one while it works.
- **A notification when you are in another window**: when an answer is in, or when Claude asks something. The terminal puts it up the way it has (kitty's, Ghostty's, foot's and iTerm2's own; WezTerm's, Konsole's and GNOME's; a bell elsewhere), and only while the window is not in front. `CURD_NOTIFY=off` turns it off.
- **Links**: a web address in an answer is a link the terminal opens on a click (with Ctrl or Cmd held, in most).
- **Problems as curly underlines**, red for an error and yellow for a warning, in the dark and light looks.
- **The cursor is a bar** in a line of text being typed, and as you have it elsewhere.
- **The clipboard**: Alt+C and copying in the editor go to the system clipboard through the terminal (OSC 52), where it allows that.

## Code editing

- **Status bar:** made of parts that keep their places. On the left the file's name, `[modified]` in yellow while there are unsaved changes, and the counts of errors (red) and warnings (yellow); a message, a question or the problem on the cursor line takes that side while it is there. On the right the git branch, the language and the cursor position; on a narrow screen the branch and then the language give way.
- **Line numbers** in a column on the left.
- **Tabs and wide characters:** a tab in a file is drawn up to the next multiple of four columns, and characters that take two cells in a terminal (Chinese, Japanese, Korean, most emoji) take two here, so the cursor, clicks, selections and sideways scrolling are where the text is. Marks that join the letter before them (a separate accent) are not drawn. The Tab key still types spaces.
- **Undo and redo:** Ctrl+Z takes back the last step and Ctrl+Y does it again. A step is a word typed in one go, a paste, a snippet or a suggestion. Undoing back to what was saved clears the `[modified]` mark.
- **Search:** Ctrl+F (or Alt+F) asks in the status bar and jumps to the first match as you type, with every match on screen shown in reverse. Enter or Down goes to the next match, Up to the one before, wrapping round the file. It ignores case unless you type a capital letter. After Esc, F3 (or Alt+N) repeats the search.
- **Replace:** Ctrl+R (or Alt+R) asks what to find, then what to put in its place. Enter replaces the match under the cursor and moves to the next, Down skips one, Alt+A replaces every match in the file as one step to undo, Esc stops.
- **Search the project:** Alt+S asks for the text and lists every line in the project's files that holds it (files git ignores, files that are not text and files over 1 MB are skipped; the list stops at 2000 lines). Type to narrow the list, Enter opens the line.
- **Select, copy, cut, paste:** hold Shift while moving to select, or drag with the mouse. Ctrl+C copies and Ctrl+X cuts; with nothing selected they take the whole line. Typing replaces the selection. Copied text also goes to the system clipboard in terminals that support it (the "OSC 52" sequence); Ctrl+V pastes it, also into another tab.
- **Git menu:** Ctrl+G (or Alt+V) lists the git commands; type to narrow the list and press Enter. It can stage or unstage the file in front (or the one selected in the tree), stage or unstage everything, commit what is staged with a message, switch to another branch, create a branch, pull and push. The commands run in the background and the status bar says how they went, in git's own words when they fail. Switching branch and pulling ask you to save first, and afterwards open files show what is on disk. A push of a branch that was never pushed goes to `origin`. Git is never allowed to ask for a password on the editor's screen: a command that needs one fails instead, so set up a credential helper or an SSH agent.
- **History (the commit graph):** Alt+Y, or a click on **commits** in the status bar, opens, in a tab of its own, every commit on every branch, newest first, with the lines of the graph showing where branches part and merge. Each commit has its short name, the branches and tags that point at it, the first line of its message, who made it and how long ago. Move through it and search it (Ctrl+F finds a message, a name or a branch) like any text, and press Enter on a commit to open it: its message, the files it changed and the changes themselves, in the colours of the diff view. Enter on a changed line there goes to that line in its file. "History of this file" in the git menu lists only the commits that changed the file in front.
- **Who last changed a line:** in a file that is in git, the line the cursor is on says, in faint text after its end, who last changed it, how long ago and in which commit (`Ada, 3 days ago · Fix the parser`), or `Not committed yet`. It is only shown while the text is as saved, since git knows the file on disk. "Show the commit that last changed this line" in the git menu opens that commit. "Show or hide who last changed the line" turns it off and on; `CURD_BLAME=off curd` starts with it off. Only the file in front is asked about, in the background.
- **Changes (the diff view):** F4 opens, in a tab of its own, what changed in the file since the last commit; Shift+F4 does it for the whole project. Lines put in are green and lines taken out red. It is for looking, not editing: move through it, search it, copy from it, and press Enter on a line to go to that line in its file. It compares the files as they are on disk, so save first. It is the way to look over what Claude (or you) changed before a commit.
- **The branch's name** in the status bar and at the foot of the file tree can be clicked to switch branch.
- **Files changed elsewhere:** when you come back to the terminal, open files that another program changed are read again, unless they have unsaved changes.
- **Save as:** Ctrl+S in a file with no name asks for one in the status bar. It never overwrites a file that already exists.
- **Folding:** lines that start a block have a `-` beside their line number. Alt+K (or Ctrl+K) collapses the block into one row, shown as `fn main() { ... }` with a `+`; the same key opens it again. Alt+A folds every top-level block so the whole file's outline fits on screen, and unfolds everything again; a click on the `-` or `+` does one block. Blocks are `{ ... }` in most languages and indentation in Python and YAML. Folding only changes the view, never the file.
- **Auto-indent:** Enter keeps the current indentation and adds a level after `{`, `(` or `[` (and after `:` in Python and YAML). Typing `}` on a blank line steps back a level. One level is four spaces, or two in YAML.
- **Paste:** pasted text goes in exactly as copied, without auto-indent.
- **Snippets:** type a trigger word and press Tab. Which ones exist depends on the file extension:

| Language | Triggers |
|---|---|
| Rust (`.rs`) | `fn` `main` `struct` `enum` `impl` `match` `if` `for` `while` `loop` `test` `tests` `pl` |
| Python (`.py`) | `def` `class` `if` `for` `while` `main` `try` |
| JavaScript / TypeScript | `fn` `afn` `if` `for` `while` `log` |
| C / C++ | `main` `if` `for` `while` `inc` |
| Go (`.go`) | `fn` `main` `if` `for` `err` |

For example, in a `.rs` file `main` + Tab becomes:

```rust
fn main() {
    |
}
```

`curd new-file.txt` starts an empty document and creates the file on the first save. The bottom row is a status bar with the file name, a `[modified]` marker and the cursor position.

-- rex_open.lua: a picker, Alt+Cmd+O, for the files, folders, links, commands
-- and SQL in the focused pane's output, and its directory.
--
-- It works on the focused pane, whatever runs in it. In a pane running
-- Claude Code with the rex-open plugin, the directory follows Claude's
-- cd; elsewhere it's the directory of the pane's program.
--
-- Load it from init.lua with setup, which can change the picker (see
-- DEFAULT_PICKER):
--   require("rex_open").setup{ picker = { key = "alt+cmd+p" } }

local M = {}

local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"

local function basename(path)
  return (path:gsub("/+$", ""):match("([^/]+)$")) or path
end

-- Directory from the terminal's reported pwd (OSC 7 file:// URL).
local function reported_pwd(block_id)
  local r = rex.block.call(TERMINAL, "pwd", { block_id = block_id })
  if not r or type(r.pwd) ~= "string" then return nil end
  local path = r.pwd:gsub("^file://[^/]*", "")
  path = path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
  if path == "" then return nil end
  return path
end

-- Directory Claude Code last reported through the plugin's hook
-- (hooks/save-cwd.sh), which follows its cd. The file holds Claude's
-- pid and then the directory. It's used only while that pid is still the
-- pane's foreground process, so a file left behind by a Claude that has
-- exited, or by another program, is ignored.
local STATE_DIR = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/rex-open"

local function hook_cwd(block_id, pid)
  local f = io.open(STATE_DIR .. "/" .. block_id:gsub("^block:", ""), "r")
  if not f then return nil end
  local saved_pid, path = f:read("*l"), f:read("*l")
  f:close()
  if not saved_pid or saved_pid == "" or tonumber(saved_pid) ~= pid then return nil end
  if path and path ~= "" then return path end
end

-- The focused pane's directory: Claude's, from the hook, when the pane runs
-- Claude Code with the plugin; else the directory of the pane's program, or
-- the one the shell last reported.
local function pane_dir(ctx)
  local id = ctx.block_id
  if not id then error("no focused pane", 0) end
  local proc = rex.block.call(TERMINAL, "process", { block_id = id })
  local fg = proc and proc.foreground
  local dir = (fg and hook_cwd(id, fg.pid)) or (fg and fg.cwd) or reported_pwd(id)
  if not dir then error("couldn't find the focused pane's directory", 0) end
  return dir, id
end

-- A terminal in dir. With cmd, it runs cmd.run with /bin/sh, with cmd.args
-- as $1, $2, ..., in the login shell's environment, or types cmd.input into
-- the shell.
local function pane_in(dir, cmd)
  local options = { cwd = dir, initial_input = cmd and cmd.input }
  if cmd and cmd.run then
    options.command = { "/bin/sh", "-c", cmd.run, "sh" }
    for _, a in ipairs(cmd.args or {}) do options.command[#options.command + 1] = a end
  end
  return rex.layout.block{ flavor = SHELL, options = options }
end

local SPLITS = {
  right = { direction = "horizontal", side = "after",  title = "Right" },
  left  = { direction = "horizontal", side = "before", title = "Left" },
  down  = { direction = "vertical",   side = "after",  title = "Down" },
  up    = { direction = "vertical",   side = "before", title = "Up" },
}

-- Opens a terminal in dir, as a new tab (where == "tab") or a split of the
-- focused pane, optionally running cmd. label names a new tab.
local function open_pane(ctx, where, dir, cmd, label)
  if where == "tab" then
    local w, err = rex.session.new_window{
      window_label = label or basename(dir),
      focus  = true,
      layout = pane_in(dir, cmd),
    }
    if not w then error(err, 0) end
    return { window_id = w.window_id }
  end

  local s = SPLITS[where]
  local r, err = rex.session.new_split{
    anchor_id = ctx.block_id,
    direction = s.direction,
    side      = s.side,
    focus     = true,
    layout    = pane_in(dir, cmd),
  }
  if not r then error(err, 0) end
  return { block_id = r.block_ids and r.block_ids[1] }
end

local function bind_keys(keys, action)
  if type(keys) == "string" then keys = { keys } end
  if type(keys) == "table" then
    for _, key in ipairs(keys) do rex.bind(key, action) end
  end
end

-- The picker (rex_open). It reads the focused pane's recent output and finds paths
-- that exist (absolute, ~/, or relative to the pane's directory; files may
-- end in :line) and commands it showed as code, and lists them after the
-- pane's directory, in the command palette. A second list asks how to open
-- the row: where open says, in a new tab, below, or copied. A file opens in
-- your editor, a folder as a shell there, and a command typed into a shell,
-- not run. Change it with setup{ picker = { ... } }.
--   key   the key for rex_open
--   open  where it opens first: right, left, down, up or tab, beside the
--         pane you were in (float is an old name for right)
--   view  shell code that opens file $1, at line $2 when the agent gave one
--         ($2 is empty otherwise). Defaults to DEFAULT_VIEW.

-- Opens $1 at line $2 in $VISUAL or $EDITOR, or read-only vim when neither is
-- set. Rex starts panes with the login shell's environment, which leaves out
-- variables set in an interactive shell's startup file such as ~/.zshrc, so
-- it asks an interactive shell when they're missing. Editors it knows get the
-- line in their own syntax; others just get the file.
M.DEFAULT_VIEW = [=[
ed=${VISUAL:-$EDITOR}
if [ -z "$ed" ] && [ -n "$SHELL" ]; then
  ed=$("$SHELL" -ic 'printf "\n@ed@%s\n" "${VISUAL:-$EDITOR}"' </dev/null 2>/dev/null |
    sed -n 's/^@ed@//p' | tail -n 1)
fi
line=${2:-1}
case $(basename "${ed%% *}") in
  "") vim -R "+$line" -- "$1" ;;
  vi|vim|nvim|view|nano|emacs|micro|kak|mg) eval "$ed \"+\$line\" \"\$1\"" ;;
  hx|helix|zed|subl) eval "$ed \"\$1:\$line\"" ;;
  code|code-insiders|cursor|windsurf) eval "$ed -g \"\$1:\$line\"" ;;
  *) eval "$ed \"\$1\"" ;;
esac
]=]

M.DEFAULT_PICKER = {
  key  = "alt+cmd+o",
  open = "right",
  view = M.DEFAULT_VIEW,
}
local PICKER_FIELDS = { key = true, open = true, view = true }
local picker = {}
for k, v in pairs(M.DEFAULT_PICKER) do picker[k] = v end

local OUTPUT_BYTES = 512 * 1024  -- how much of the pane's latest output to read
local MAX_PATHS    = 40          -- most paths and commands to offer

-- The pane's latest output as HTML, at most OUTPUT_BYTES of it. HTML keeps
-- the colors, which show what the agent marked as code.
local function recent_output(block_id)
  local r = rex.block.call(TERMINAL, "format",
    { block_id = block_id, format = "html", unwrap = true, max_bytes = OUTPUT_BYTES })
  if not r or type(r.content) ~= "string" then return "" end
  if not r.id or not r.total or r.total <= #r.content then return r.content end
  -- Read the last OUTPUT_BYTES. A read can return less than asked even
  -- before the end, so keep reading until it says it reached the end.
  local parts, offset = {}, r.total - OUTPUT_BYTES
  for _ = 1, 64 do
    local part = rex.block.call(TERMINAL, "blob_read",
      { block_id = block_id, id = r.id, offset = offset, max_bytes = OUTPUT_BYTES })
    if not part or type(part.data) ~= "string" or part.data == "" then break end
    parts[#parts + 1] = part.data
    offset = offset + #part.data
    if part.eof then break end
  end
  if #parts == 0 then return r.content end
  return (table.concat(parts):gsub("^[^\n]*\n", ""))  -- drop the partial first line
end

-- "file" for a readable file, "dir" for a folder, nil for anything else.
-- Devices such as /dev/null don't count.
local function path_kind(path)
  if path:match("^/dev/") then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
  local _, err = f:read(1)
  f:close()
  if err == nil then return "file" end
  if tostring(err):find("directory", 1, true) then return "dir" end
end

local HOME = os.getenv("HOME") or ""

-- Splits a token such as `src/app.ts:42:7`, into (path, line).
local function parse_token(tok)
  tok = tok:gsub("^file://[^/]*", "")
  tok = tok:gsub("[%.:,;!?]+$", "")
  local path, line = tok:match("^(.-):(%d+):%d+$")
  if not path then path, line = tok:match("^(.-):(%d+)$") end
  return path or tok, line
end

-- An absolute path with "." and ".." parts collapsed.
local function normalize(path)
  local parts = {}
  for p in path:gmatch("[^/]+") do
    if p == ".." then
      if #parts > 0 then parts[#parts] = nil end
    elseif p ~= "." then
      parts[#parts + 1] = p
    end
  end
  return "/" .. table.concat(parts, "/")
end

-- The absolute path the token names and its kind, or nil. Folders need a
-- slash in the token, and the pane's own folder and / are left out.
local function resolve(tok, dir)
  if tok:find("://", 1, true) then return nil end
  local has_slash = tok:find("/", 1, true)
  if not (has_slash or tok:find("%.%w+$")) then return nil end
  local path = tok
  if path == "~" or path:sub(1, 2) == "~/" then
    path = HOME .. path:sub(2)
  elseif path:sub(1, 1) ~= "/" then
    path = dir:gsub("/+$", "") .. "/" .. path:gsub("^%./", "")
  end
  path = normalize(path)
  local kind = path_kind(path)
  if kind == "dir" then
    path = path:gsub("/+$", "")
    if not has_slash or path == "/" or path == normalize(dir) then return nil end
  end
  if kind then return path, kind end
end

-- A folder as the picker shows it: relative to dir when inside it ("" for dir
-- itself), else with ~, and with the middle left out when it's long.
local function short_dir(path, dir)
  dir = dir:gsub("/+$", "")
  if path == dir then return "" end
  if path:sub(1, #dir + 1) == dir .. "/" then
    path = path:sub(#dir + 2)
  elseif HOME ~= "" and (path == HOME or path:sub(1, #HOME + 1) == HOME .. "/") then
    path = "~" .. path:sub(#HOME + 1)
  end
  if #path <= 32 then return path end
  local parts = {}
  for p in path:gmatch("[^/]+") do parts[#parts + 1] = p end
  if #parts <= 3 then return path end
  local head = (path:sub(1, 1) == "/" and "/" or "") .. parts[1]
  local short = head .. "/…/" .. parts[#parts - 1] .. "/" .. parts[#parts]
  if #short > 40 then short = head .. "/…/" .. parts[#parts] end
  return short
end

-- How a path shows in the picker, as a title and subtitle: its name, then
-- its folder.
local function display(f, dir)
  if f.kind == "cmd" then return "$ " .. f.path, "command" end
  if f.kind == "sql" then
    local shown = f.path:gsub("%s+", " ")
    if #shown > 70 then shown = shown:sub(1, 69) .. "…" end
    return shown, "sql"
  end
  if f.kind == "url" then
    local shown = f.path:gsub("^https?://", ""):gsub("^www%.", "")
    if #shown > 60 then shown = shown:sub(1, 59) .. "…" end
    return shown, "link"
  end
  local name = basename(f.path) .. (f.kind == "dir" and "/" or "") ..
               (f.line and (":" .. f.line) or "")
  local parent = short_dir(f.path:match("^(.*)/[^/]*$") or "/", dir)
  if parent == "" then return name end
  return name, parent
end

local TOKEN = "[^%s`'\"<>%(%)%[%]{}|,;]+"

-- UTF-8 for a code point, for the numeric entities in Rex's HTML.
local function utf8_char(n)
  if n < 0x80 then return string.char(n) end
  if n < 0x800 then return string.char(0xC0 + math.floor(n / 0x40), 0x80 + n % 0x40) end
  if n < 0x10000 then
    return string.char(0xE0 + math.floor(n / 0x1000), 0x80 + math.floor(n / 0x40) % 0x40, 0x80 + n % 0x40)
  end
  return string.char(0xF0 + math.floor(n / 0x40000), 0x80 + math.floor(n / 0x1000) % 0x40,
                     0x80 + math.floor(n / 0x40) % 0x40, 0x80 + n % 0x40)
end

local function unescape(s)
  s = s:gsub("<[^>]*>", "")
  s = s:gsub("&#(%d+);", function(n) return utf8_char(tonumber(n)) end)
  s = s:gsub("&quot;", '"'):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")
  return s
end

-- Splits Rex's HTML into lines, each with its text, the pieces drawn in a
-- color (how agents show code), and whether any of it has a background (how
-- they show the prompt you typed). A piece the agent wrapped onto the next
-- line, which ends the line with a space, is joined with the piece that
-- starts the next line.
local function html_lines(html)
  html = html:gsub('^<div style="font%-family[^"]*">', "")
  local lines = {}
  for l in (html .. "\n"):gmatch("([^\n]*)\n") do
    local text, code, bg, pos = {}, {}, false, 1
    local code_starts, code_ends = false, false
    while true do
      local s, e, style, inner = l:find('<div style="([^"]*)">(.-)</div>', pos)
      if not s then break end
      local before = unescape(l:sub(pos, s - 1))
      text[#text + 1] = before
      local piece = unescape(inner)
      text[#text + 1] = piece
      code_ends = false
      if style:find("background", 1, true) then
        bg = true
      elseif style:find(";color:", 1, true) or style:sub(1, 6) == "color:" then
        if #text == 2 and before:match("^%s*$") then code_starts = true end
        code[#code + 1] = piece
        code_ends = true
      end
      pos = e + 1
    end
    local after = unescape(l:sub(pos))
    text[#text + 1] = after
    if not after:match("^%s*$") then code_ends = false end
    lines[#lines + 1] = { text = table.concat(text), code = code, bg = bg,
                          code_starts = code_starts, code_ends = code_ends }
  end
  for i = 1, #lines - 1 do
    local l, nl = lines[i], lines[i + 1]
    if l.code_ends and nl.code_starts and l.code[#l.code]:match("%s$") then
      l.code[#l.code] = l.code[#l.code] .. nl.code[1]
    end
  end
  return lines
end

-- What your interactive shell sets up: its PATH (tools such as nvm add to it
-- in ~/.zshrc, which Rex doesn't read) and your editor ($VISUAL, else
-- $EDITOR). Asked once, on first use, and kept until Rex reloads its config,
-- because starting an interactive shell can take most of a second.
local shell_env
local function get_shell_env()
  if shell_env then return shell_env end
  shell_env = { program_dirs = {}, editor = os.getenv("VISUAL") or os.getenv("EDITOR") or "" }
  local dirs, seen = shell_env.program_dirs, {}
  local function add_path(p)
    for d in (p or ""):gmatch("[^:]+") do
      if not seen[d] then seen[d] = true; dirs[#dirs + 1] = d end
    end
  end
  local shell = os.getenv("SHELL")
  if shell and shell ~= "" then
    local r = rex.exec({ shell, "-ic", 'printf "\\n@path@%s\\n@editor@%s\\n" "$PATH" "${VISUAL:-$EDITOR}"' },
                       { stdin = "", timeout = 5 })
    if r and r.stdout then
      add_path(r.stdout:match("@path@([^\n]*)"))
      if shell_env.editor == "" then shell_env.editor = r.stdout:match("@editor@([^\n]*)") or "" end
    end
  end
  add_path(os.getenv("PATH"))
  add_path("/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:" .. HOME .. "/.local/bin")
  return shell_env
end
local SHELL_WORDS = { cd = true, source = true, ["."] = true, export = true, eval = true, exec = true }
local programs = {}

-- Whether word runs something: an executable script, a shell builtin, or a
-- program in your shell's PATH.
local function is_program(word, dir)
  if word:find("/", 1, true) then
    local p = word
    if p:sub(1, 2) == "~/" then p = HOME .. p:sub(2)
    elseif p:sub(1, 1) ~= "/" then p = dir:gsub("/+$", "") .. "/" .. p:gsub("^%./", "") end
    if path_kind(p) ~= "file" then return false end
    -- A script must be executable, so a file path such as notes/todo.md isn't.
    local r = rex.exec({ "test", "-x", p }, { timeout = 2 })
    return r ~= nil and r.ok
  end
  if SHELL_WORDS[word] then return true end
  if programs[word] == nil then
    programs[word] = false
    for _, d in ipairs(get_shell_env().program_dirs) do
      if path_kind(d .. "/" .. word) == "file" then programs[word] = true; break end
    end
  end
  return programs[word]
end

-- The command in text, or nil. It must start with a program. A single word
-- counts only when it's a script path or loose is set (a whole code line, or
-- text after "! " or "$ ", which agents use for "type this").
local function as_command(text, dir, loose)
  local cmd = text:gsub("^%s+", ""):gsub("%s+$", "")
  local prompt = cmd:match("^[!$] +")
  if prompt then cmd, loose = cmd:sub(#prompt + 1), true end
  if cmd == "" or #cmd > 300 or cmd:find("\t", 1, true) then return nil end
  local words = {}
  for w in cmd:gmatch("%S+") do words[#words + 1] = w end
  local i = 1
  while words[i] and words[i]:match("^[%a_][%w_]*=") do  -- FOO=bar cmd
    -- An assignment from a subshell, as in x=$(...), is shell code, not a
    -- command to run.
    if words[i]:find("$(", 1, true) or words[i]:find("`", 1, true) then return nil end
    i = i + 1
  end
  local first = words[i]
  -- Programs are lowercase: macOS finds "claude" for "Claude", so a capital
  -- would let words like the start of a sentence through.
  if not first or not first:match("^[%l%d%._~/+-]+$") or not is_program(first, dir) then return nil end
  if i == #words and not loose and not first:find("/", 1, true) then return nil end
  return cmd
end

-- Commands the agent showed on a line: the whole line when it's a line of
-- code (some of it colored, starting with a program, not a sentence), else
-- each colored piece that is a command. Lines with a background are the
-- prompt you typed, and are skipped.
local function line_commands(l, dir)
  if l.bg then return {} end
  local trimmed = l.text:gsub("^%s+", ""):gsub("%s+$", "")
  if trimmed:match("^[!$] ") then
    local c = as_command(trimmed, dir, true)
    return c and { c } or {}
  end
  if #l.code == 0 then return {} end
  if not trimmed:find("[%.:?,;]$") and not trimmed:find("[%.?!] %u") then
    local c = as_command(trimmed, dir, true)
    if c then return { c } end
  end
  local cmds = {}
  for _, piece in ipairs(l.code) do
    local c = as_command(piece, dir, false)
    if c then cmds[#cmds + 1] = c end
  end
  return cmds
end

-- Words that start a SQL statement.
local SQL_START = {
  select = true, with = true, insert = true, update = true, delete = true, create = true,
  alter = true, drop = true, explain = true, merge = true, truncate = true, grant = true,
}
-- The first word of s when it starts a SQL statement: all capitals, or all
-- lowercase when the statement has another SQL word, so "Update the README"
-- and "select a file" aren't.
local function sql_word(s, whole)
  local w = s:match("^%s*(%a+)")
  if not w or not SQL_START[w:lower()] then return nil end
  if w == w:upper() then return w end
  if w == w:lower() then
    local lw = " " .. whole:lower() .. " "
    for _, k in ipairs({ "from", "into", "set", "table", "where", "values", "index", "view" }) do
      if lw:find("%W" .. k .. "%W") then return w end
    end
  end
  return nil
end

-- SQL statements the agent showed, as { [line index] = { statements } }. A
-- statement starts with a colored SQL word, at the start of a line or as a
-- colored piece of one, and a line that starts one runs on to the line that
-- ends with ";", or to a blank line. Agents color only some words in a code
-- block, so the lines after the first needn't be colored.
local function sql_statements(hl)
  local at = {}
  local function put(i, sql) at[i] = at[i] or {}; table.insert(at[i], sql) end
  local i = 1
  while i <= #hl do
    local l = hl[i]
    local nexti = i + 1
    if not l.bg and #l.code > 0 then
      -- The line without a leading bullet, such as Claude's "⏺ ".
      local text = l.text:gsub("^%s*[^%w%s]*%s+", ""):gsub("^%s+", ""):gsub("%s+$", "")
      local word = sql_word(text, text) or (text:match("^%a+") and sql_word(text, text .. " from "))
      local colored = false
      for _, piece in ipairs(l.code) do
        if word and piece:gsub("^%s+", ""):sub(1, #word) == word then colored = true; break end
      end
      if colored then
        local parts, j = { text }, i
        local indent
        while not parts[#parts]:find(";%s*$") and j < #hl and j - i < 80 do
          local nl = hl[j + 1]
          if nl.bg or nl.text:match("^%s*$") then break end
          local lead = #nl.text:match("^%s*")
          indent = indent and math.min(indent, lead) or lead
          parts[#parts + 1] = nl.text
          j = j + 1
        end
        for k = 2, #parts do parts[k] = parts[k]:sub((indent or 0) + 1):gsub("%s+$", "") end
        local sql = table.concat(parts, "\n")
        if sql_word(text, sql) then put(i, sql); nexti = j + 1 end
      else
        for _, piece in ipairs(l.code) do
          local p = piece:gsub("^%s+", ""):gsub("%s+$", "")
          if #p > 8 and p:find("%s") and sql_word(p, p) then put(i, p) end
        end
      end
    end
    i = nexti
  end
  return at
end

-- Web links in a line of text, last first, without trailing punctuation.
local function line_urls(text)
  local urls = {}
  for u in text:gmatch("https?://[^%s<>\"'`]+") do
    u = u:gsub("[%.,;:!?]+$", "")
    -- Drop a closing bracket the link didn't open, as in "(see https://x.y)".
    while u:match("[%)%]]$") do
      local close = u:sub(-1)
      local open = close == ")" and "%(" or "%["
      local _, opens = u:gsub(open, "")
      local _, closes = u:gsub("%" .. close, "")
      if closes > opens then u = u:sub(1, -2) else break end
    end
    if #u > #"https://x.y" then table.insert(urls, 1, u) end
  end
  return urls
end

-- Commands and SQL ahead of everything else, each group keeping its order,
-- so a command wins over a script it runs when both match what was typed.
local function commands_first(found)
  local out = {}
  local function first(f) return f.kind == "cmd" or f.kind == "sql" end
  for _, f in ipairs(found) do if first(f) then out[#out + 1] = f end end
  for _, f in ipairs(found) do if not first(f) then out[#out + 1] = f end end
  return out
end

-- Paths, commands and SQL the agent mentioned, commands and SQL first, then
-- newest first, as { path, kind, line } tables. kind is "file", "dir", "cmd",
-- "sql" or "url"; for a command, SQL or a link, path is its text.
local function mentioned_paths(html, dir)
  local hl = html_lines(html)
  local lines = {}
  for i, l in ipairs(hl) do lines[i] = l.text end

  local found, seen = {}, {}
  local function add(path, kind, line)
    local key = ((kind == "cmd" or kind == "sql") and kind .. " " or "") .. path
    local f = seen[key]
    if f then
      -- Keep the newest mention's place, and a line number from an older one.
      f.line = f.line or line
      return
    end
    f = { path = path, kind = kind, line = kind == "file" and line or nil }
    seen[key] = f
    found[#found + 1] = f
  end

  local sql = sql_statements(hl)
  for i = #lines, 1, -1 do
    for _, q in ipairs(sql[i] or {}) do add(q, "sql") end
    for _, c in ipairs(line_commands(hl[i], dir)) do add(c, "cmd") end
    for _, u in ipairs(line_urls(lines[i])) do add(u, "url") end
    local toks = {}
    for t in lines[i]:gmatch(TOKEN) do toks[#toks + 1] = t end
    for j = #toks, 1, -1 do
      local path, line = parse_token(toks[j])
      local full, kind = resolve(path, dir)
      -- A long path the program's own display wrapped onto the next line.
      if (not full or kind == "dir") and j == #toks and lines[i + 1] then
        local rest = lines[i + 1]:match("^%s*(" .. TOKEN .. ")")
        if rest then
          local p2, l2 = parse_token(toks[j] .. rest)
          local f2, k2 = resolve(p2, dir)
          if f2 then full, kind, line = f2, k2, l2 end
        end
      end
      if full then add(full, kind, line) end
      if #found >= MAX_PATHS then return commands_first(found) end
    end
  end
  return commands_first(found)
end

-- Copies text to the clipboard.
local function copy(text)
  local r = rex.exec({ "/bin/sh", "-c", [[
if command -v pbcopy >/dev/null 2>&1; then exec pbcopy
elif [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then exec wl-copy
elif command -v xclip >/dev/null 2>&1; then exec xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then exec xsel --clipboard --input
fi
exit 127]] }, { stdin = text, timeout = 5 })
  if not (r and r.ok) then error("rex_open: couldn't copy; no clipboard program found", 0) end
end

-- Opens a link in your browser.
local function open_url(url)
  rex.exec({ "/bin/sh", "-c",
             'if command -v open >/dev/null 2>&1; then open "$1"; else xdg-open "$1"; fi', "sh", url },
           { stdout = false, stderr = false, timeout = 10 })
end

-- Where picker.open opens things. float is its old name for right.
local OPEN = { float = "right", right = "right", left = "left", down = "down", up = "up", tab = "tab" }
local WHERE_TITLES = {
  right = "Open to the right", left = "Open to the left",
  down = "Open below", up = "Open above", tab = "Open in a new tab",
}
local ICONS = { file = "document", dir = "folder", cmd = "terminal", sql = "database", url = "link" }

-- Asks how to open f: where picker.open says first, so Enter twice does what
-- Enter did, then a new tab, below, or copy. Returns a where or "copy", or
-- nil when cancelled.
local function ask_how(f)
  local items
  if f.kind == "url" then
    items = { { id = "browser", title = "Open in your browser", icon = "globe" } }
  else
    local first = OPEN[picker.open]
    items = { { id = first, title = WHERE_TITLES[first] } }
    for _, w in ipairs({ "tab", "down" }) do
      if w ~= first then items[#items + 1] = { id = w, title = WHERE_TITLES[w] } end
    end
    if f.kind == "cmd" then
      for _, it in ipairs(items) do it.subtitle = "typed into a new shell, not run" end
    end
  end
  items[#items + 1] = { id = "copy", title = "Copy to the clipboard" }
  local how, why = rex.ui.pick{ title = (display(f, f.dir)), items = items }
  if how == nil and why ~= "cancelled" then rex.log("warn", "rex_open: " .. why) end
  return how
end

-- Opens f, a row the picker found, as how says.
local function open_found(ctx, f, how)
  if how == "copy" or f.kind == "sql" then return copy(f.path) end
  if f.kind == "url" then return open_url(f.path) end
  if f.kind == "dir" then return open_pane(ctx, how, f.path, nil, basename(f.path)) end
  if f.kind == "cmd" then
    return open_pane(ctx, how, f.dir, { input = f.path }, f.path:sub(1, 24))
  end
  local run = 'rex_open_ed=$3; set -- "$1" "$2"\n' ..
              '[ -z "${VISUAL:-$EDITOR}" ] && [ -n "$rex_open_ed" ] && export VISUAL="$rex_open_ed"\n' ..
              'unset rex_open_ed\n' .. picker.view
  return open_pane(ctx, how, f.path:match("^(.*)/[^/]*$") or "/",
                   { run = run, args = { f.path, f.line or "", get_shell_env().editor } },
                   basename(f.path))
end

-- Opens the focused pane's directory, or a path, link or command in its
-- output. With nothing found, it opens a shell in the pane's directory;
-- otherwise it asks, in the command palette, which one, with that directory
-- first, then commands, then the rest, newest first, and then how to open it.
local function open_agent(ctx)
  local dir, block_id = pane_dir(ctx)
  local found = mentioned_paths(recent_output(block_id), dir)
  if #found == 0 then
    return open_pane(ctx, OPEN[picker.open], dir, nil, basename(dir))
  end

  table.insert(found, 1, { path = dir, kind = "dir", current = true })
  local items = {}
  for i, f in ipairs(found) do
    f.dir = dir
    local title, subtitle = display(f, dir)
    if f.current then title, subtitle = basename(dir) .. "/", "current directory" end
    items[i] = { id = tostring(i), title = title, subtitle = subtitle, icon = ICONS[f.kind] }
  end
  local id, why = rex.ui.pick{
    title       = "Open from " .. basename(dir),
    placeholder = "Filter paths, links and commands",
    items       = items,
  }
  if id == nil then
    if why ~= "cancelled" then rex.log("warn", "rex_open: " .. why) end
    return
  end
  local f = found[tonumber(id)]
  local how = f.kind == "sql" and "copy" or ask_how(f)
  if how then return open_found(ctx, f, how) end
end

rex.action{
  name        = "rex_open",
  title       = "Open a Path, Link or Command from This Pane",
  description = "Opens a picker with the focused pane's directory and the files, folders, links, commands and SQL in its recent output.",
  category    = "Pane",
  keywords    = "agent claude cwd directory folder file path link url command sql copy clipboard open view mentioned recent picker tab split",
  run         = function(ctx) return open_agent(ctx) end,
}

-- Binds the picker's key.
--   picker  changes the picker's key, where it opens, or how files open
--           (DEFAULT_PICKER), or is false to leave it unbound.
local SETUP_FIELDS = { picker = true }

function M.setup(opts)
  opts = opts or {}
  for f in pairs(opts) do
    if not SETUP_FIELDS[f] then
      error("rex_open: setup has unknown field '" .. tostring(f) .. "'; it takes picker", 0)
    end
  end

  -- picker changes rex_open's key, where it opens, or its viewer.
  -- picker = false leaves it unbound.
  if opts.picker ~= false then
    for f, v in pairs(opts.picker or {}) do
      if not PICKER_FIELDS[f] then error("rex_open: picker has unknown field '" .. tostring(f) .. "'", 0) end
      picker[f] = v
    end
    if not OPEN[picker.open] then
      error("rex_open: picker has open = '" .. tostring(picker.open) .. "'; use right, left, down, up or tab", 0)
    end
    if type(picker.view) ~= "string" or picker.view == "" then
      error("rex_open: picker needs view = \"...\"", 0)
    end
    bind_keys(picker.key, "rex_open")
  end
end

return M

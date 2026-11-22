

-- >>> rex-open: a picker for the files, folders, links, commands and SQL in a pane's output.
require("rex_open").setup{
  -- Alt+Cmd+O opens a picker: the focused pane's directory, then the files,
  -- folders, links, commands and SQL in its output. Enter opens to the right,
  -- Ctrl-T in a new tab, Ctrl-D below, and Ctrl-Y copies.
  picker = {
    -- A key, a list of keys, or false to leave it unbound.
    key  = "alt+cmd+o",
    -- float: a popup over the window, and Enter opens to the right.
    -- right, left, down, up or tab: the picker opens there, and so does Enter.
    open = "float",
    -- How a file opens. By default: in $VISUAL or $EDITOR at the line, or
    -- read-only vim when neither is set. To choose, set view: $1 is the file
    -- and $2 the line. Others: 'nvim -R "+${2:-1}" -- "$1"', 'hx "$1:${2:-1}"'.
    -- view = 'vim -R "+${2:-1}" -- "$1"',
  },
}
-- <<< rex-open

rex.bind("alt+shift+j", "session.next")
rex.bind("alt+shift+k", "session.previous")
rex.action{
  name     = "focus_direction",
  title    = "Focus Pane in Direction",
  category = "Pane",
  args     = { direction = "string" },
  run      = function(ctx, args)
    local v, err = rex.session.view{}
    if not v then error(err, 0) end
    local _, ferr = rex.call("session.focus_direction", { session_id = v.session_id, direction = args.direction })
    if ferr then error(ferr, 0) end
  end,
}
rex.bind("alt+h", "focus_direction", { direction = "left" })
rex.bind("alt+j", "focus_direction", { direction = "down" })
rex.bind("alt+k", "focus_direction", { direction = "up" })
rex.bind("alt+l", "focus_direction", { direction = "right" })
rex.bind("alt+shift+h", "client.tab.previous")
rex.bind("alt+shift+l", "client.tab.next")
rex.bind("alt+s", "pane.split.down")
rex.bind("alt+v", "pane.split.right")
rex.action{
  name     = "close_pane_or_session",
  title    = "Close Pane, or Session on Its Last Pane",
  category = "Pane",
  run      = function(ctx)
    local v, err = rex.session.view{}
    if not v then error(err, 0) end
    local blocks = 0
    for _, w in ipairs(v.windows) do
      for _, l in ipairs(w.layers) do blocks = blocks + #l.blocks end
    end
    if blocks > 1 then
      rex.client.queue("pane.close", {})
      return
    end
    rex.call("session.attach", { session_id = v.session_id })
    local _, derr = rex.call("session.destroy", { session_id = v.session_id })
    if derr then error(derr, 0) end
  end,
}
rex.bind("alt+q", "close_pane_or_session")

rex.bind("alt+b", "client.sidebar.activity.by_priority")

local function list_agents()
  local r, err = rex.call("session.list", {})
  if not r then error(err, 0) end
  local agents = {}
  for _, s in ipairs(r.sessions) do
    rex.call("session.attach", { session_id = s.session_id })
    local v = rex.call("session.view", { session_id = s.session_id })
    for _, w in ipairs(v and v.windows or {}) do
      for _, l in ipairs(w.layers) do
        for _, b in ipairs(l.blocks) do
          local st = rex.call("block.method", { session_id = s.session_id, block_id = b.block_id, method = "program_status" })
          local rec = st and st.records and st.records[1]
          if rec then
            agents[#agents + 1] = { order = #agents, state = rec.state, session_id = s.session_id, block_id = b.block_id }
          end
        end
      end
    end
  end
  return agents
end

local function focus_agent(a)
  rex.call("session.attach", { session_id = a.session_id })
  local _, err = rex.call("session.focus_block", { session_id = a.session_id, block_id = a.block_id })
  if err then error(err, 0) end
  rex.client.queue("session.select", { session_id = a.session_id })
end

rex.action{
  name     = "go_to_agent",
  title    = "Go to Agent N",
  category = "Session",
  args     = { index = "number" },
  run      = function(ctx, args)
    local a = list_agents()[args.index]
    if a then focus_agent(a) end
  end,
}
for i = 1, 9 do rex.bind("alt+" .. i, "go_to_agent", { index = i }) end

local attention_rank = { blocked = 1, done = 2, error = 3 }
rex.action{
  name     = "next_attention",
  title    = "Go to Next Agent Needing Attention",
  category = "Session",
  run      = function(ctx)
    local cur = rex.session.view{}
    local cur_block
    for _, w in ipairs(cur and cur.windows or {}) do
      if w.window_id == cur.active_window_id then cur_block = w.focused_block_id end
    end
    local found = {}
    for _, a in ipairs(list_agents()) do
      a.rank = attention_rank[a.state]
      if a.rank then found[#found + 1] = a end
    end
    if #found == 0 then return end
    table.sort(found, function(a, b)
      if a.rank ~= b.rank then return a.rank < b.rank end
      return a.order < b.order
    end)
    local pick = found[1]
    for i, f in ipairs(found) do
      if f.block_id == cur_block then pick = found[i % #found + 1] end
    end
    focus_agent(pick)
  end,
}
rex.bind("alt+space", "next_attention")

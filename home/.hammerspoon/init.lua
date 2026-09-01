-- ~/.hammerspoon/init.lua

local apps = {
  ["1"] = "Ghostty",
  ["2"] = "Firefox",
  ["3"] = "Slack",
  ["4"] = "IntelliJ IDEA",
}

local hyper = {"cmd", "alt", "ctrl", "shift"}

for key, appName in pairs(apps) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(appName)
  end)
end

-- Reload config with Hyper-R.
hs.hotkey.bind(hyper, "R", hs.reload)
hs.alert.show("Hammerspoon config loaded")

-- Keep `hs -c 'hs.reload()'` available for config reloads and diagnostics.
require("hs.ipc")

local mods = { "ctrl", "alt" }
local deck = "English Grammar"

local function ac(action, params)
  local request = { action = action, version = 6, params = params }
  hs.http.asyncPost("http://127.0.0.1:8765", hs.json.encode(request), {
    ["Content-Type"] = "application/json",
  }, function(status, body)
    if status ~= 200 then
      hs.alert.show("AnkiConnect: hãy mở Anki và bật add-on AnkiConnect.")
      return
    end
    local ok, response = pcall(hs.json.decode, body)
    if not ok or type(response) ~= "table" then
      hs.alert.show("AnkiConnect: phản hồi không hợp lệ.")
    elseif response.error then
      hs.alert.show("AnkiConnect: " .. tostring(response.error))
    elseif response.result == false then
      hs.alert.show("Anki: hãy vào chế độ ôn tập và hiện đáp án trước khi chấm điểm.")
    end
  end)
end

-- Call AnkiConnect directly: no activation or synthetic keys sent to Anki.
hs.hotkey.bind(mods, "space", function()
  ac("guiShowAnswer")
end)
for ease, key in ipairs({ "n", "m", ",", "." }) do
  hs.hotkey.bind(mods, key, function()
    ac("guiAnswerCard", { ease = ease })
  end)
end
hs.hotkey.bind(mods, "z", function()
  ac("guiUndo")
end)
hs.hotkey.bind(mods, "d", function()
  ac("guiDeckReview", { name = deck })
end)

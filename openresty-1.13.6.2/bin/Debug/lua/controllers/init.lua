-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

return function(app)
  --
  require(cwd .. "home")(app)
  require(cwd .. "login")(app)
  require(cwd .. "news")(app)
  require(cwd .. "stats")(app)
  
  require(cwd .. "game")(app)

end
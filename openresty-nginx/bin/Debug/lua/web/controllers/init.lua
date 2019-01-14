-- Localize
local cwd = (...) .. "."

return function(app)
  --
  require(cwd .. "login")(app)
  require(cwd .. "home")(app)
  require(cwd .. "admin_news")(app)
  require(cwd .. "admin_mail")(app)
  require(cwd .. "admin_game_announcement")(app)
  require(cwd .. "player")(app)
  require(cwd .. "stats")(app)

end
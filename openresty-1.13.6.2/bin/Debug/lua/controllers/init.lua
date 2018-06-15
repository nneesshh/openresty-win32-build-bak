-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

return function(app)
  --
  require(cwd .. "home")(app)
  require(cwd .. "login")(app)

end
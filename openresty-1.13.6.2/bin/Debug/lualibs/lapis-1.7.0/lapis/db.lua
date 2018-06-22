local config = require("lapis.config").get()
if config.postgres then
  local db = require("lapis.db.postgres")
  db.init()
  return db
elseif config.mysql then
  local db = require("lapis.db.mysql")
  db.init()
  return db
else
  return error("You have to configure either postgres or mysql")
end

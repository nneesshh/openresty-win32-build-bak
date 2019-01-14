local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local lapis = require("lapis")
local db = require("lapis.db")

local uuid = require("uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local oss_options = require(cwd .. "GameDbUrls").getOptions()

local _M = {
  _db_entity = Model:extend(oss_options, "_oss_stats_retention", {
    primary_key = "day"
  }),
}

function _M.get(theDay) 
  return _M._db_entity:find({ day = theDay })
end

function _M.getPage(theDay) 
  local paginated = _M._db_entity:paginated("WHERE day >= ? ORDER BY DAY ASC", theDay, { 
    per_page = 10,
    prepare_results = function(posts)
      --Users:include_in(posts, "user_id")
      return posts
  end
  })

  local page1 = paginated:get_page(1)
  return page1
end

return _M
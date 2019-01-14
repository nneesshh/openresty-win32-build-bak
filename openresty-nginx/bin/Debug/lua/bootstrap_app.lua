--
require "bootstrap"

--local int64 = require "int64"
local pb = require "pb"
local json = require "rapidjson"

local randseed = math.randomseed
local rand = math.random
local rand_init = function()
  math.randomseed(os.time())
  math.random(1, 10000)
end
rand_init()

--[[]]
require "Gate_pb"
require "Game_pb"
require "Guild_pb"
require "UserItem_pb"
require "UserOrder_pb"
require "UserFacility_pb"
require "UserShip_pb"
require "UserSailor_pb"
require "UserNavigation_pb"
require "UserBean_pb"
require "UserExplore_pb"
require "UserHarbour_pb"
require "UserHunt_pb"
require "NPC_pb"
require "Task_pb"
require "Manual_pb"
require "Development_pb"
require "Chat_pb"
require "UserMap_pb"
require "Chest_pb"
require "Development_pb"
require "Friend_pb"
require "Equip_pb"
require "UserTreasureMap_pb"
require "Pvp_pb"
require "PVE_pb"
require "Shop_pb"
require "Mail_pb"
require "PVE_pb"
require "PVPMatch_pb"
require "PVPBattle_pb"
require "GM_pb"
--[[]]

local pb = require("StoredProcConfig_pb")
local split = require("utils.split")

local _M = {
    --
    _db_options = false,
    _redis_options = {
        host = "127.0.0.1",
        port = 6379,
    },
    
    --
    _db_url = "Server=127.0.0.1;Database=sandbox;Uid=root;Pwd=123123;CharSet=utf8;SslMode=None",
    _module_name = "{sandbox}",
    _preload = true,
    _dump = false,
    
    --
    _entities = {
        { proto = pb.ConfigAchievement, tbl = "config_achievement", key = "id", subkey = false },
        { proto = pb.ConfigAchievementTask, },
        { proto = pb.ConfigBaseRoom, },
        { proto = pb.ConfigBusinessman, },
        { proto = pb.ConfigCard, },
        { proto = pb.ConfigCardAttribute, },
        { proto = pb.ConfigCardEquip, },
        { proto = pb.ConfigCardEquipStrengthen, },
        { proto = pb.ConfigCardLevel, },
        { proto = pb.ConfigCardList, },
        { proto = pb.ConfigCardPractice, },
        { proto = pb.ConfigCardStrengthen, },
        { proto = pb.ConfigCardStrengthenList, },
        { proto = pb.ConfigCardTalent, },
        { proto = pb.ConfigChest, },
        { proto = pb.ConfigDropItemGroup, },
        { proto = pb.ConfigDungeonContentGroup, },
        { proto = pb.ConfigDungeonEvent, },
        { proto = pb.ConfigDungeonStoreGroup, },
        { proto = pb.ConfigDungeonTalent, },
        { proto = pb.ConfigDungeonTalentTree, },
        { proto = pb.ConfigEasterEgg, },
        { proto = pb.ConfigEnemy, },
        { proto = pb.ConfigEnemyEvent, },
        { proto = pb.ConfigEnemyGroup, },
        { proto = pb.ConfigEquipAttributeWord, },
        { proto = pb.ConfigEquipDecompose, },
        { proto = pb.ConfigEquipDecomposeCost, },
        { proto = pb.ConfigEquipRefineCost, },
        { proto = pb.ConfigExploreEvent, },
        { proto = pb.ConfigFacility, },
        { proto = pb.ConfigFacilityGroup, },
        { proto = pb.ConfigFacilityList, },
        { proto = pb.ConfigFarmSkillLevel, },
        { proto = pb.ConfigFightElementConnect, },
        { proto = pb.ConfigFightItem, },
        { proto = pb.ConfigFightMachine, },
        { proto = pb.ConfigFightRandomGroup, },
        { proto = pb.ConfigFormula, },
        { proto = pb.ConfigGhostShip, },
        { proto = pb.ConfigItem, },
        { proto = pb.ConfigItemList, },
        { proto = pb.ConfigLevel, },
        { proto = pb.ConfigLevelList, },
        { proto = pb.ConfigLottery, },
        { proto = pb.ConfigMachineExchange, },
        { proto = pb.ConfigMachineExchangeGroup, },
        { proto = pb.ConfigModel, },
        { proto = pb.ConfigNpc, },
        { proto = pb.ConfigNpcInFight, },
        { proto = pb.ConfigPlace, },
        { proto = pb.ConfigPveMapModel, },
        { proto = pb.ConfigPvePlayerDrop, },
        { proto = pb.ConfigPveRoomModel, },
        { proto = pb.ConfigRandomGift, },
        { proto = pb.ConfigRankingBattleReward, },
        { proto = pb.ConfigRankingReward, },
        { proto = pb.ConfigRankingScore, },
        { proto = pb.ConfigScene, },
        { proto = pb.ConfigSecretRoom, },
        { proto = pb.ConfigSecretRoomGroup, },
        { proto = pb.ConfigShopping, },
        { proto = pb.ConfigShoppingVitality, },
        { proto = pb.ConfigSkill, },
        { proto = pb.ConfigSkillRandom, },
        { proto = pb.ConfigSpecialEvent, },
        { proto = pb.ConfigSystemTask, },
        { proto = pb.ConfigTask, },
        { proto = pb.ConfigTaskStep, },
        { proto = pb.ConfigWanted, },
        { proto = pb.ConfigWildIslandLevel, },
    },
   
}

local function _getDbOptions(db_url)
  local parsed = {}
  
  for param in split.each(db_url, '%s*;%s*') do
      local k, v = split.first(param, '%s*=%s*')
      parsed[k] = v
  end
 
  local host = parsed.Server or "127.0.0.1"
  local port = parsed.Port or 3306
  local path = parsed.Path
  local database = assert(parsed.Database, "`database` missing from config for resty_mysql")
  local user = assert(parsed.Uid, "`user` missing from config for resty_mysql")
  local password = parsed.Pwd
  local ssl = parsed.Ssl
  local ssl_verify = parsed.SslVerify
  local timeout = parsed.Timeout or 10000
  local max_idle_timeout = parsed.MaxIdleTimeout or 10000
  local pool_size = parsed.PoolSize or 100
  
  local options = {
    database = database,
    user = user,
    password = password,
    ssl = ssl,
    ssl_verify = ssl_verify,
    charset = "utf8",
  }
  
  if path then
    options.path = path
  else
    options.host = host
    options.port = port
  end
  
  options.pool = user .. ":" .. database .. ":" .. host .. ":" .. port
  
  return options
end

function _M.getDbOptions()
  if not _M._db_options then
    _M._db_options = _getDbOptions(_M._db_url)
  end
  return _M._db_options
end

function _M.getRedisOptions()
  if not _M._redis_options then
    _M._redis_options = {
      host = "127.0.0.1",
      port = 6379
    }
  end
  return _M._redis_options
end

return _M
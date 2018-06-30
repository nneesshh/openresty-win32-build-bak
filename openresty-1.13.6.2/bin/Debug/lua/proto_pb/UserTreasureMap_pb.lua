-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
local BASESTRUCT_PB = require("BaseStruct_pb")
local _M = {}
_G.UserTreasureMap_pb = _M


local localTable = {}
localTable.TREASURE_MAP_TYPE = protobuf.EnumDescriptor()
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_UNKNOWN_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_UNKNOWN = 0
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_COMPASS_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_COMPASS = 1
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_MAP_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_MAP = 2
_M.E_TREASURE_MAP_TYPE_MAX = 2

localTable.TREASURE_LOCATION_TYPE = protobuf.EnumDescriptor()
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_UNKNOWN_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_UNKNOWN = 0
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_SEA_AREA_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_SEA_AREA = 1
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_HARBOR_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_HARBOR = 2
_M.E_TREASURE_LOCATION_TYPE_MAX = 2

localTable.TREASURE_TRIGGER_TYPE = protobuf.EnumDescriptor()
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_NONE_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_NONE = 0
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_FIGHT_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_FIGHT = 1
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TREASURE_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TREASURE = 2
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TRAP_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TRAP = 3
_M.E_TREASURE_TRIGGER_TYPE_MAX = 3

localTable.TREASURE_HUNT_STATE = protobuf.EnumDescriptor()
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_IDLE_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_IDLE = 0
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HUNT_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HUNT = 1
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT = 2
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HARVEST_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HARVEST = 3
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_TRAPPED_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_TRAPPED = 4
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_OVER_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_OVER = 5
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_CANCELED_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_CANCELED = 6
_M.E_TREASURE_HUNT_STATE_MAX = 6

localTable.TREASURE_TRAP_TYPE = protobuf.EnumDescriptor()
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_NONE_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_NONE = 0
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_REEF_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_REEF = 1
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_POISON_ENUM = protobuf.EnumValueDescriptor()
_M.E_TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_POISON = 2
_M.E_TREASURE_TRAP_TYPE_MAX = 2

_M.TREASUREHUNTINFO_META = protobuf.Descriptor()
localTable.TREASUREHUNTINFO_HUNTID_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_TOOLID_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_STATE_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_AREAID_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_COORD_X_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_COORD_Y_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREHUNTINFO_OPTIME_FIELD = protobuf.FieldDescriptor()
_M.USERTREASUREMAPSERVICE_META = protobuf.Descriptor()
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META = protobuf.Descriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD = protobuf.FieldDescriptor()
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META = protobuf.Descriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND = protobuf.EnumDescriptor()
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_QUERY_ENUM = protobuf.EnumValueDescriptor()
_M.E_USERTREASUREMAPSERVICE_HUNT_COMMAND_QUERY = 1
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_START_ENUM = protobuf.EnumValueDescriptor()
_M.E_USERTREASUREMAPSERVICE_HUNT_COMMAND_START = 2
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_COMPLETE_ENUM = protobuf.EnumValueDescriptor()
_M.E_USERTREASUREMAPSERVICE_HUNT_COMMAND_COMPLETE = 3
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_CANCEL_ENUM = protobuf.EnumValueDescriptor()
_M.E_USERTREASUREMAPSERVICE_HUNT_COMMAND_CANCEL = 4
_M.E_USERTREASUREMAPSERVICE_HUNT_COMMAND_MAX = 4

localTable.USERTREASUREMAPSERVICE_REQ_FIELD = protobuf.FieldDescriptor()
localTable.USERTREASUREMAPSERVICE_RESP_FIELD = protobuf.FieldDescriptor()
_M.TREASUREMAPSTATENOTIFY_META = protobuf.Descriptor()
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD = protobuf.FieldDescriptor()
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD = protobuf.FieldDescriptor()


localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_UNKNOWN_ENUM.name = "TREASURE_MAP_TYPE_UNKNOWN"
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_UNKNOWN_ENUM.index = 0
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_UNKNOWN_ENUM.number = 0
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_COMPASS_ENUM.name = "TREASURE_MAP_TYPE_COMPASS"
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_COMPASS_ENUM.index = 1
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_COMPASS_ENUM.number = 1
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_MAP_ENUM.name = "TREASURE_MAP_TYPE_MAP"
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_MAP_ENUM.index = 2
localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_MAP_ENUM.number = 2
localTable.TREASURE_MAP_TYPE.name = "TREASURE_MAP_TYPE"
localTable.TREASURE_MAP_TYPE.full_name = ".sg.TREASURE_MAP_TYPE"
localTable.TREASURE_MAP_TYPE.values = {localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_UNKNOWN_ENUM,localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_COMPASS_ENUM,localTable.TREASURE_MAP_TYPE_TREASURE_MAP_TYPE_MAP_ENUM}
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_UNKNOWN_ENUM.name = "TREASURE_LOCATION_TYPE_UNKNOWN"
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_UNKNOWN_ENUM.index = 0
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_UNKNOWN_ENUM.number = 0
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_SEA_AREA_ENUM.name = "TREASURE_LOCATION_TYPE_SEA_AREA"
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_SEA_AREA_ENUM.index = 1
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_SEA_AREA_ENUM.number = 1
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_HARBOR_ENUM.name = "TREASURE_LOCATION_TYPE_HARBOR"
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_HARBOR_ENUM.index = 2
localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_HARBOR_ENUM.number = 2
localTable.TREASURE_LOCATION_TYPE.name = "TREASURE_LOCATION_TYPE"
localTable.TREASURE_LOCATION_TYPE.full_name = ".sg.TREASURE_LOCATION_TYPE"
localTable.TREASURE_LOCATION_TYPE.values = {localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_UNKNOWN_ENUM,localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_SEA_AREA_ENUM,localTable.TREASURE_LOCATION_TYPE_TREASURE_LOCATION_TYPE_HARBOR_ENUM}
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_NONE_ENUM.name = "TREASURE_TRIGGER_TYPE_NONE"
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_NONE_ENUM.index = 0
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_NONE_ENUM.number = 0
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_FIGHT_ENUM.name = "TREASURE_TRIGGER_TYPE_FIGHT"
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_FIGHT_ENUM.index = 1
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_FIGHT_ENUM.number = 1
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TREASURE_ENUM.name = "TREASURE_TRIGGER_TYPE_TREASURE"
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TREASURE_ENUM.index = 2
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TREASURE_ENUM.number = 2
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TRAP_ENUM.name = "TREASURE_TRIGGER_TYPE_TRAP"
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TRAP_ENUM.index = 3
localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TRAP_ENUM.number = 3
localTable.TREASURE_TRIGGER_TYPE.name = "TREASURE_TRIGGER_TYPE"
localTable.TREASURE_TRIGGER_TYPE.full_name = ".sg.TREASURE_TRIGGER_TYPE"
localTable.TREASURE_TRIGGER_TYPE.values = {localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_NONE_ENUM,localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_FIGHT_ENUM,localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TREASURE_ENUM,localTable.TREASURE_TRIGGER_TYPE_TREASURE_TRIGGER_TYPE_TRAP_ENUM}
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_IDLE_ENUM.name = "TREASURE_HUNT_STATE_IDLE"
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_IDLE_ENUM.index = 0
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_IDLE_ENUM.number = 0
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HUNT_ENUM.name = "TREASURE_HUNT_STATE_HUNT"
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HUNT_ENUM.index = 1
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HUNT_ENUM.number = 1
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_ENUM.name = "TREASURE_HUNT_STATE_FIGHT"
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_ENUM.index = 2
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_ENUM.number = 2
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HARVEST_ENUM.name = "TREASURE_HUNT_STATE_HARVEST"
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HARVEST_ENUM.index = 3
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HARVEST_ENUM.number = 3
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_TRAPPED_ENUM.name = "TREASURE_HUNT_STATE_TRAPPED"
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_TRAPPED_ENUM.index = 4
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_TRAPPED_ENUM.number = 4
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_OVER_ENUM.name = "TREASURE_HUNT_STATE_FIGHT_OVER"
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_OVER_ENUM.index = 5
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_OVER_ENUM.number = 5
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_CANCELED_ENUM.name = "TREASURE_HUNT_STATE_CANCELED"
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_CANCELED_ENUM.index = 6
localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_CANCELED_ENUM.number = 6
localTable.TREASURE_HUNT_STATE.name = "TREASURE_HUNT_STATE"
localTable.TREASURE_HUNT_STATE.full_name = ".sg.TREASURE_HUNT_STATE"
localTable.TREASURE_HUNT_STATE.values = {localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_IDLE_ENUM,localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HUNT_ENUM,localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_ENUM,localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_HARVEST_ENUM,localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_TRAPPED_ENUM,localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_FIGHT_OVER_ENUM,localTable.TREASURE_HUNT_STATE_TREASURE_HUNT_STATE_CANCELED_ENUM}
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_NONE_ENUM.name = "TREASURE_TRAP_TYPE_NONE"
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_NONE_ENUM.index = 0
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_NONE_ENUM.number = 0
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_REEF_ENUM.name = "TREASURE_TRAP_TYPE_REEF"
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_REEF_ENUM.index = 1
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_REEF_ENUM.number = 1
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_POISON_ENUM.name = "TREASURE_TRAP_TYPE_POISON"
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_POISON_ENUM.index = 2
localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_POISON_ENUM.number = 2
localTable.TREASURE_TRAP_TYPE.name = "TREASURE_TRAP_TYPE"
localTable.TREASURE_TRAP_TYPE.full_name = ".sg.TREASURE_TRAP_TYPE"
localTable.TREASURE_TRAP_TYPE.values = {localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_NONE_ENUM,localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_REEF_ENUM,localTable.TREASURE_TRAP_TYPE_TREASURE_TRAP_TYPE_POISON_ENUM}
localTable.TREASUREHUNTINFO_HUNTID_FIELD.name = "huntid"
localTable.TREASUREHUNTINFO_HUNTID_FIELD.full_name = ".sg.TreasureHuntInfo.huntid"
localTable.TREASUREHUNTINFO_HUNTID_FIELD.number = 1
localTable.TREASUREHUNTINFO_HUNTID_FIELD.index = 0
localTable.TREASUREHUNTINFO_HUNTID_FIELD.label = 2
localTable.TREASUREHUNTINFO_HUNTID_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_HUNTID_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_HUNTID_FIELD.type = 5
localTable.TREASUREHUNTINFO_HUNTID_FIELD.cpp_type = 1

localTable.TREASUREHUNTINFO_TOOLID_FIELD.name = "toolid"
localTable.TREASUREHUNTINFO_TOOLID_FIELD.full_name = ".sg.TreasureHuntInfo.toolid"
localTable.TREASUREHUNTINFO_TOOLID_FIELD.number = 2
localTable.TREASUREHUNTINFO_TOOLID_FIELD.index = 1
localTable.TREASUREHUNTINFO_TOOLID_FIELD.label = 2
localTable.TREASUREHUNTINFO_TOOLID_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_TOOLID_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_TOOLID_FIELD.type = 5
localTable.TREASUREHUNTINFO_TOOLID_FIELD.cpp_type = 1

localTable.TREASUREHUNTINFO_STATE_FIELD.name = "state"
localTable.TREASUREHUNTINFO_STATE_FIELD.full_name = ".sg.TreasureHuntInfo.state"
localTable.TREASUREHUNTINFO_STATE_FIELD.number = 3
localTable.TREASUREHUNTINFO_STATE_FIELD.index = 2
localTable.TREASUREHUNTINFO_STATE_FIELD.label = 1
localTable.TREASUREHUNTINFO_STATE_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_STATE_FIELD.default_value = nil
localTable.TREASUREHUNTINFO_STATE_FIELD.enum_type = localTable.TREASURE_HUNT_STATE
localTable.TREASUREHUNTINFO_STATE_FIELD.type = 14
localTable.TREASUREHUNTINFO_STATE_FIELD.cpp_type = 8

localTable.TREASUREHUNTINFO_AREAID_FIELD.name = "areaid"
localTable.TREASUREHUNTINFO_AREAID_FIELD.full_name = ".sg.TreasureHuntInfo.areaid"
localTable.TREASUREHUNTINFO_AREAID_FIELD.number = 4
localTable.TREASUREHUNTINFO_AREAID_FIELD.index = 3
localTable.TREASUREHUNTINFO_AREAID_FIELD.label = 1
localTable.TREASUREHUNTINFO_AREAID_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_AREAID_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_AREAID_FIELD.type = 5
localTable.TREASUREHUNTINFO_AREAID_FIELD.cpp_type = 1

localTable.TREASUREHUNTINFO_COORD_X_FIELD.name = "coord_x"
localTable.TREASUREHUNTINFO_COORD_X_FIELD.full_name = ".sg.TreasureHuntInfo.coord_x"
localTable.TREASUREHUNTINFO_COORD_X_FIELD.number = 5
localTable.TREASUREHUNTINFO_COORD_X_FIELD.index = 4
localTable.TREASUREHUNTINFO_COORD_X_FIELD.label = 1
localTable.TREASUREHUNTINFO_COORD_X_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_COORD_X_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_COORD_X_FIELD.type = 5
localTable.TREASUREHUNTINFO_COORD_X_FIELD.cpp_type = 1

localTable.TREASUREHUNTINFO_COORD_Y_FIELD.name = "coord_y"
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.full_name = ".sg.TreasureHuntInfo.coord_y"
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.number = 6
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.index = 5
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.label = 1
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.type = 5
localTable.TREASUREHUNTINFO_COORD_Y_FIELD.cpp_type = 1

localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.name = "monster_group"
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.full_name = ".sg.TreasureHuntInfo.monster_group"
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.number = 11
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.index = 6
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.label = 1
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.type = 5
localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD.cpp_type = 1

localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.name = "trap_type"
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.full_name = ".sg.TreasureHuntInfo.trap_type"
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.number = 21
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.index = 7
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.label = 1
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.default_value = nil
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.enum_type = localTable.TREASURE_TRAP_TYPE
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.type = 14
localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD.cpp_type = 8

localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.name = "trap_lost_num"
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.full_name = ".sg.TreasureHuntInfo.trap_lost_num"
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.number = 22
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.index = 8
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.label = 1
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.type = 5
localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD.cpp_type = 1

localTable.TREASUREHUNTINFO_OPTIME_FIELD.name = "optime"
localTable.TREASUREHUNTINFO_OPTIME_FIELD.full_name = ".sg.TreasureHuntInfo.optime"
localTable.TREASUREHUNTINFO_OPTIME_FIELD.number = 31
localTable.TREASUREHUNTINFO_OPTIME_FIELD.index = 9
localTable.TREASUREHUNTINFO_OPTIME_FIELD.label = 1
localTable.TREASUREHUNTINFO_OPTIME_FIELD.has_default_value = false
localTable.TREASUREHUNTINFO_OPTIME_FIELD.default_value = 0
localTable.TREASUREHUNTINFO_OPTIME_FIELD.type = 16
localTable.TREASUREHUNTINFO_OPTIME_FIELD.cpp_type = 2

_M.TREASUREHUNTINFO_META.name = "TreasureHuntInfo"
_M.TREASUREHUNTINFO_META.full_name = ".sg.TreasureHuntInfo"
_M.TREASUREHUNTINFO_META.nested_types = {}
_M.TREASUREHUNTINFO_META.enum_types = {}
_M.TREASUREHUNTINFO_META.fields = {localTable.TREASUREHUNTINFO_HUNTID_FIELD, localTable.TREASUREHUNTINFO_TOOLID_FIELD, localTable.TREASUREHUNTINFO_STATE_FIELD, localTable.TREASUREHUNTINFO_AREAID_FIELD, localTable.TREASUREHUNTINFO_COORD_X_FIELD, localTable.TREASUREHUNTINFO_COORD_Y_FIELD, localTable.TREASUREHUNTINFO_MONSTER_GROUP_FIELD, localTable.TREASUREHUNTINFO_TRAP_TYPE_FIELD, localTable.TREASUREHUNTINFO_TRAP_LOST_NUM_FIELD, localTable.TREASUREHUNTINFO_OPTIME_FIELD}
_M.TREASUREHUNTINFO_META.is_extendable = false
_M.TREASUREHUNTINFO_META.extensions = {}
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.name = "cmd"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapRequest.cmd"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.number = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.index = 0
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.label = 2
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.default_value = nil
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.enum_type = localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.type = 14
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD.cpp_type = 8

localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.name = "itemid"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapRequest.itemid"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.number = 2
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.index = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.default_value = 0
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.type = 4
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD.cpp_type = 4

localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.name = "areaid"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapRequest.areaid"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.number = 3
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.index = 2
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.default_value = 0
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.type = 5
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD.cpp_type = 1

localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.name = "coord_x"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapRequest.coord_x"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.number = 4
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.index = 3
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.default_value = 0
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.type = 5
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD.cpp_type = 1

localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.name = "coord_y"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapRequest.coord_y"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.number = 5
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.index = 4
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.default_value = 0
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.type = 5
localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD.cpp_type = 1

_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.name = "TreasureMapRequest"
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.full_name = ".sg.UserTreasureMapService.TreasureMapRequest"
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.nested_types = {}
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.enum_types = {}
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.fields = {localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_CMD_FIELD, localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_ITEMID_FIELD, localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_AREAID_FIELD, localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_X_FIELD, localTable.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_COORD_Y_FIELD}
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.is_extendable = false
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.extensions = {}
_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META.containing_type = _M.USERTREASUREMAPSERVICE_META
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.name = "result"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapResponse.result"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.number = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.index = 0
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.label = 2
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.default_value = 0
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.type = 5
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD.cpp_type = 1

localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.name = "hunt_info"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapResponse.hunt_info"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.number = 2
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.index = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.default_value = nil
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.message_type = _M.TREASUREHUNTINFO_META
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.type = 11
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD.cpp_type = 10

localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.name = "out_drop"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.full_name = ".sg.UserTreasureMapService.TreasureMapResponse.out_drop"
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.number = 11
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.index = 2
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.default_value = nil
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.message_type = BASESTRUCT_PB.REWARD_META
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.type = 11
localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD.cpp_type = 10

_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.name = "TreasureMapResponse"
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.full_name = ".sg.UserTreasureMapService.TreasureMapResponse"
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.nested_types = {}
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.enum_types = {}
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.fields = {localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_RESULT_FIELD, localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_HUNT_INFO_FIELD, localTable.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_OUT_DROP_FIELD}
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.is_extendable = false
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.extensions = {}
_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META.containing_type = _M.USERTREASUREMAPSERVICE_META
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_QUERY_ENUM.name = "QUERY"
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_QUERY_ENUM.index = 0
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_QUERY_ENUM.number = 1
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_START_ENUM.name = "START"
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_START_ENUM.index = 1
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_START_ENUM.number = 2
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_COMPLETE_ENUM.name = "COMPLETE"
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_COMPLETE_ENUM.index = 2
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_COMPLETE_ENUM.number = 3
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_CANCEL_ENUM.name = "CANCEL"
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_CANCEL_ENUM.index = 3
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_CANCEL_ENUM.number = 4
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND.name = "HUNT_COMMAND"
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND.full_name = ".sg.UserTreasureMapService.HUNT_COMMAND"
localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND.values = {localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_QUERY_ENUM,localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_START_ENUM,localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_COMPLETE_ENUM,localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND_CANCEL_ENUM}
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.name = "req"
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.full_name = ".sg.UserTreasureMapService.req"
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.number = 1
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.index = 0
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.default_value = nil
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.message_type = _M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.type = 11
localTable.USERTREASUREMAPSERVICE_REQ_FIELD.cpp_type = 10

localTable.USERTREASUREMAPSERVICE_RESP_FIELD.name = "resp"
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.full_name = ".sg.UserTreasureMapService.resp"
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.number = 2
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.index = 1
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.label = 1
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.has_default_value = false
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.default_value = nil
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.message_type = _M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.type = 11
localTable.USERTREASUREMAPSERVICE_RESP_FIELD.cpp_type = 10

_M.USERTREASUREMAPSERVICE_META.name = "UserTreasureMapService"
_M.USERTREASUREMAPSERVICE_META.full_name = ".sg.UserTreasureMapService"
_M.USERTREASUREMAPSERVICE_META.nested_types = {USERTREASUREMAPSERVICE_TREASUREMAPREQUEST, USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE}
_M.USERTREASUREMAPSERVICE_META.enum_types = {localTable.USERTREASUREMAPSERVICE_HUNT_COMMAND}
_M.USERTREASUREMAPSERVICE_META.fields = {localTable.USERTREASUREMAPSERVICE_REQ_FIELD, localTable.USERTREASUREMAPSERVICE_RESP_FIELD}
_M.USERTREASUREMAPSERVICE_META.is_extendable = false
_M.USERTREASUREMAPSERVICE_META.extensions = {}
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.name = "hunt_info"
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.full_name = ".sg.TreasureMapStateNotify.hunt_info"
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.number = 1
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.index = 0
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.label = 2
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.has_default_value = false
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.default_value = nil
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.message_type = _M.TREASUREHUNTINFO_META
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.type = 11
localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD.cpp_type = 10

localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.name = "out_drop"
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.full_name = ".sg.TreasureMapStateNotify.out_drop"
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.number = 11
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.index = 1
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.label = 1
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.has_default_value = false
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.default_value = nil
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.message_type = BASESTRUCT_PB.REWARD_META
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.type = 11
localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD.cpp_type = 10

_M.TREASUREMAPSTATENOTIFY_META.name = "TreasureMapStateNotify"
_M.TREASUREMAPSTATENOTIFY_META.full_name = ".sg.TreasureMapStateNotify"
_M.TREASUREMAPSTATENOTIFY_META.nested_types = {}
_M.TREASUREMAPSTATENOTIFY_META.enum_types = {}
_M.TREASUREMAPSTATENOTIFY_META.fields = {localTable.TREASUREMAPSTATENOTIFY_HUNT_INFO_FIELD, localTable.TREASUREMAPSTATENOTIFY_OUT_DROP_FIELD}
_M.TREASUREMAPSTATENOTIFY_META.is_extendable = false
_M.TREASUREMAPSTATENOTIFY_META.extensions = {}

_M.TreasureHuntInfo = protobuf.Message(_M.TREASUREHUNTINFO_META)
_M.TreasureMapStateNotify = protobuf.Message(_M.TREASUREMAPSTATENOTIFY_META)
_M.UserTreasureMapService = protobuf.Message(_M.USERTREASUREMAPSERVICE_META)
_M.UserTreasureMapService.TreasureMapRequest = protobuf.Message(_M.USERTREASUREMAPSERVICE_TREASUREMAPREQUEST_META)
_M.UserTreasureMapService.TreasureMapResponse = protobuf.Message(_M.USERTREASUREMAPSERVICE_TREASUREMAPRESPONSE_META)

return _M
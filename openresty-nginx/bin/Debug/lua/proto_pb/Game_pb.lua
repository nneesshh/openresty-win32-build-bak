-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
local _M = {}
_G.Game_pb = _M


local localTable = {}
_M.GAMESERVICE_META = protobuf.Descriptor()
_M.GAMESERVICE_GAMEREQUEST_META = protobuf.Descriptor()
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD = protobuf.FieldDescriptor()
_M.GAMESERVICE_GAMERESPONSE_META = protobuf.Descriptor()
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD = protobuf.FieldDescriptor()
localTable.GAMESERVICE_CMD = protobuf.EnumDescriptor()
localTable.GAMESERVICE_CMD_QUERY_ENUM = protobuf.EnumValueDescriptor()
_M.E_GAMESERVICE_CMD_QUERY = 1
_M.E_GAMESERVICE_CMD_MAX = 1

localTable.GAMESERVICE_REQ_FIELD = protobuf.FieldDescriptor()
localTable.GAMESERVICE_RESP_FIELD = protobuf.FieldDescriptor()
_M.GAMEANNOUNCEMENTNOTIFY_META = protobuf.Descriptor()
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD = protobuf.FieldDescriptor()
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD = protobuf.FieldDescriptor()


localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.name = "cmd"
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.full_name = ".sg.GameService.GameRequest.cmd"
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.number = 1
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.index = 0
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.label = 2
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.has_default_value = false
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.default_value = nil
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.enum_type = localTable.GAMESERVICE_CMD
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.type = 14
localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD.cpp_type = 8

_M.GAMESERVICE_GAMEREQUEST_META.name = "GameRequest"
_M.GAMESERVICE_GAMEREQUEST_META.full_name = ".sg.GameService.GameRequest"
_M.GAMESERVICE_GAMEREQUEST_META.nested_types = {}
_M.GAMESERVICE_GAMEREQUEST_META.enum_types = {}
_M.GAMESERVICE_GAMEREQUEST_META.fields = {localTable.GAMESERVICE_GAMEREQUEST_CMD_FIELD}
_M.GAMESERVICE_GAMEREQUEST_META.is_extendable = false
_M.GAMESERVICE_GAMEREQUEST_META.extensions = {}
_M.GAMESERVICE_GAMEREQUEST_META.containing_type = _M.GAMESERVICE_META
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.name = "server_time"
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.full_name = ".sg.GameService.GameResponse.server_time"
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.number = 1
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.index = 0
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.label = 1
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.has_default_value = false
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.default_value = 0
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.type = 16
localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD.cpp_type = 2

_M.GAMESERVICE_GAMERESPONSE_META.name = "GameResponse"
_M.GAMESERVICE_GAMERESPONSE_META.full_name = ".sg.GameService.GameResponse"
_M.GAMESERVICE_GAMERESPONSE_META.nested_types = {}
_M.GAMESERVICE_GAMERESPONSE_META.enum_types = {}
_M.GAMESERVICE_GAMERESPONSE_META.fields = {localTable.GAMESERVICE_GAMERESPONSE_SERVER_TIME_FIELD}
_M.GAMESERVICE_GAMERESPONSE_META.is_extendable = false
_M.GAMESERVICE_GAMERESPONSE_META.extensions = {}
_M.GAMESERVICE_GAMERESPONSE_META.containing_type = _M.GAMESERVICE_META
localTable.GAMESERVICE_CMD_QUERY_ENUM.name = "QUERY"
localTable.GAMESERVICE_CMD_QUERY_ENUM.index = 0
localTable.GAMESERVICE_CMD_QUERY_ENUM.number = 1
localTable.GAMESERVICE_CMD.name = "CMD"
localTable.GAMESERVICE_CMD.full_name = ".sg.GameService.CMD"
localTable.GAMESERVICE_CMD.values = {localTable.GAMESERVICE_CMD_QUERY_ENUM}
localTable.GAMESERVICE_REQ_FIELD.name = "req"
localTable.GAMESERVICE_REQ_FIELD.full_name = ".sg.GameService.req"
localTable.GAMESERVICE_REQ_FIELD.number = 1
localTable.GAMESERVICE_REQ_FIELD.index = 0
localTable.GAMESERVICE_REQ_FIELD.label = 1
localTable.GAMESERVICE_REQ_FIELD.has_default_value = false
localTable.GAMESERVICE_REQ_FIELD.default_value = nil
localTable.GAMESERVICE_REQ_FIELD.message_type = _M.GAMESERVICE_GAMEREQUEST_META
localTable.GAMESERVICE_REQ_FIELD.type = 11
localTable.GAMESERVICE_REQ_FIELD.cpp_type = 10

localTable.GAMESERVICE_RESP_FIELD.name = "resp"
localTable.GAMESERVICE_RESP_FIELD.full_name = ".sg.GameService.resp"
localTable.GAMESERVICE_RESP_FIELD.number = 2
localTable.GAMESERVICE_RESP_FIELD.index = 1
localTable.GAMESERVICE_RESP_FIELD.label = 1
localTable.GAMESERVICE_RESP_FIELD.has_default_value = false
localTable.GAMESERVICE_RESP_FIELD.default_value = nil
localTable.GAMESERVICE_RESP_FIELD.message_type = _M.GAMESERVICE_GAMERESPONSE_META
localTable.GAMESERVICE_RESP_FIELD.type = 11
localTable.GAMESERVICE_RESP_FIELD.cpp_type = 10

_M.GAMESERVICE_META.name = "GameService"
_M.GAMESERVICE_META.full_name = ".sg.GameService"
_M.GAMESERVICE_META.nested_types = {GAMESERVICE_GAMEREQUEST, GAMESERVICE_GAMERESPONSE}
_M.GAMESERVICE_META.enum_types = {localTable.GAMESERVICE_CMD}
_M.GAMESERVICE_META.fields = {localTable.GAMESERVICE_REQ_FIELD, localTable.GAMESERVICE_RESP_FIELD}
_M.GAMESERVICE_META.is_extendable = false
_M.GAMESERVICE_META.extensions = {}
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.name = "type"
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.full_name = ".sg.GameAnnouncementNotify.type"
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.number = 1
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.index = 0
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.label = 2
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.has_default_value = false
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.default_value = 0
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.type = 5
localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD.cpp_type = 1

localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.name = "data"
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.full_name = ".sg.GameAnnouncementNotify.data"
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.number = 2
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.index = 1
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.label = 2
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.has_default_value = false
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.default_value = ""
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.type = 12
localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD.cpp_type = 9

_M.GAMEANNOUNCEMENTNOTIFY_META.name = "GameAnnouncementNotify"
_M.GAMEANNOUNCEMENTNOTIFY_META.full_name = ".sg.GameAnnouncementNotify"
_M.GAMEANNOUNCEMENTNOTIFY_META.nested_types = {}
_M.GAMEANNOUNCEMENTNOTIFY_META.enum_types = {}
_M.GAMEANNOUNCEMENTNOTIFY_META.fields = {localTable.GAMEANNOUNCEMENTNOTIFY_TYPE_FIELD, localTable.GAMEANNOUNCEMENTNOTIFY_DATA_FIELD}
_M.GAMEANNOUNCEMENTNOTIFY_META.is_extendable = false
_M.GAMEANNOUNCEMENTNOTIFY_META.extensions = {}

_M.GameAnnouncementNotify = protobuf.Message(_M.GAMEANNOUNCEMENTNOTIFY_META)
_M.GameService = protobuf.Message(_M.GAMESERVICE_META)
_M.GameService.GameRequest = protobuf.Message(_M.GAMESERVICE_GAMEREQUEST_META)
_M.GameService.GameResponse = protobuf.Message(_M.GAMESERVICE_GAMERESPONSE_META)

return _M
cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++
"protogen/protoc.exe" --proto_path=protos/redis/DB/ --cpp_out=output/redis/cc/DB/ protos/redis/DB/RedisLuaTableDump.proto
cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++
"protogen/protoc.exe" --proto_path=protos/pvp/ --proto_path=protos/sg/Common/ --cpp_out=output/pvp/cc/ protos/pvp/Pvp.proto
"protogen/protoc.exe" --proto_path=protos/pvp/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/pvp/lua/ protos/pvp/Pvp.proto

"protogen/protoc.exe" --proto_path=protos/pvp/DB/ --cpp_out=output/pvp/cc/DB/ protos/pvp/DB/PvpStage.proto
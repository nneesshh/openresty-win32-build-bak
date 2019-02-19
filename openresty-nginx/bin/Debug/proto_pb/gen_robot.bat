cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++
"protogen/protoc.exe" --proto_path=protos/robot --cpp_out=output/robot/cc/ protos/robot/Robot.proto
"protogen/protoc.exe" --proto_path=protos/robot --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/robot/lua/ protos/robot/Robot.proto





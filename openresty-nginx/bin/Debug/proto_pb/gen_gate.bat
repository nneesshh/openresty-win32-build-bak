cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++
"protogen/protoc.exe" --proto_path=protos/gate --cpp_out=output/gate/cc/ protos/gate/Gate.proto
"protogen/protoc.exe" --proto_path=protos/gate --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/gate/lua/ protos/gate/Gate.proto

"protogen/protoc.exe" --proto_path=protos/gate --cpp_out=output/gate/cc/ protos/gate/GateInner.proto

"protogen/protoc.exe" --proto_path=protos/gate/DB --cpp_out=output/gate/cc/DB/ protos/gate/DB/GateLog.proto
"protogen/protoc.exe" --proto_path=protos/gate/DB --cpp_out=output/gate/cc/DB/ protos/gate/DB/GateSettings.proto
"protogen/protoc.exe" --proto_path=protos/gate/DB --cpp_out=output/gate/cc/DB/ protos/gate/DB/GateAccount.proto
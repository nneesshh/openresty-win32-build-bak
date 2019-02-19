cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++
"protogen/protoc.exe" --proto_path=protos/chat --cpp_out=output/chat/cc/ protos/chat/Chat.proto
"protogen/protoc.exe" --proto_path=protos/chat --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/chat/lua/ protos/chat/Chat.proto

"protogen/protoc.exe" --proto_path=protos/chat/DB/ --cpp_out=output/chat/cc/DB/ protos/chat/DB/StoredProcChat.proto





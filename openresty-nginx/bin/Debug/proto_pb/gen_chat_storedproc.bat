cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++

"protogen/protoc.exe" --proto_path=protos/chat/DB/ --cpp_out=output/chat/cc/DB/ protos/chat/DB/StoredProcChat.proto


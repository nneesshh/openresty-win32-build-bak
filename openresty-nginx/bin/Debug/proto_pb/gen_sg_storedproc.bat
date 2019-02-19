REM # c-#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
REM xcopy /sy .\proto\gx\*.proto .\protogen\
cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --cpp_out=output/sg/cc/DB/ protos/sg/DB/UserDef.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --cpp_out=output/sg/cc/DB/ protos/sg/DB/StoredProcConfig.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --cpp_out=output/sg/cc/DB/ protos/sg/DB/StoredProcGameAssets.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --cpp_out=output/sg/cc/DB/ protos/sg/DB/StoredProcGameLog.proto
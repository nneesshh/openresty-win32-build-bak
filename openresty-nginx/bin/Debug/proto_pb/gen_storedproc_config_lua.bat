REM # c-#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
REM xcopy /sy .\proto\gx\*.proto .\protogen\
cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++

REM "protogen/protoc.exe" --proto_path=protos/sg/DB/ --cpp_out=output/sg/cc/DB/ protos/sg/DB/StoredProcConfig.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/DB/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/DB/ protos/sg/DB/StoredProcConfig.proto
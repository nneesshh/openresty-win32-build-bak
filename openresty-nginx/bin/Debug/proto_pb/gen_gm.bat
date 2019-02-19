REM # c-#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
REM xcopy /sy .\proto\gx\*.proto .\protogen\
cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/GM.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/GM.proto
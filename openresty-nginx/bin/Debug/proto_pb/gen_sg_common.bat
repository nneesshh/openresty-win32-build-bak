REM # c-#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
REM xcopy /sy .\proto\gx\*.proto .\protogen\
cls

REM #c-++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserBean.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserBean.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserShip.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserShip.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserSailor.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserSailor.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/PVPMatch.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/PVPMatch.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/PVPBattle.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/PVPBattle.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/BaseStruct.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/BaseStruct.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserRoom.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserRoom.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserItem.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserItem.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserOrder.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserOrder.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserFacility.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserFacility.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/PVE.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/PVE.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserNavigation.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserNavigation.proto


"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Chest.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Chest.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserExplore.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserExplore.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/UserHarbour.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/UserHarbour.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Shop.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Shop.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Wanted.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Wanted.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Task.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Task.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/NPC.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/NPC.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Manual.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Manual.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Game.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Game.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Achievement.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Achievement.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Development.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Development.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Lottery.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Lottery.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Equip.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Equip.proto


"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Rank.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Rank.proto


"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/GhostShip.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/GhostShip.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/EasterEgg.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/EasterEgg.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/ShipEvent.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/ShipEvent.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/DailyGift.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/DailyGift.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Maelstrom.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Maelstrom.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/PlayerInvade.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/PlayerInvade.proto

"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --cpp_out=output/sg/cc/Common/ protos/sg/Common/Multiplayer.proto
"protogen/protoc.exe" --proto_path=protos/sg/DB/ --proto_path=protos/sg/Common/ --plugin=protoc-gen-lua=".\plugin\protoc-gen-lua.bat" --lua_out=output/sg/lua/Common/ protos/sg/Common/Multiplayer.proto
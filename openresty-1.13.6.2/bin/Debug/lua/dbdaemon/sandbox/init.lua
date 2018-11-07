require("appsettings")
require("utils.functions")

local tasks = {
    --
    require("dbdaemon.sandbox.StoredProcConfig"),
  
}
require("dbdaemon.Runner")(tasks)
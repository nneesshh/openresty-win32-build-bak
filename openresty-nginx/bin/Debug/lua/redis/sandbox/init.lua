require("appsettings")

local tasks = {
    --
    require("dbdaemon.sandbox.StoredProcConfig"),
  
}
require("dbdaemon.Runner")(tasks)
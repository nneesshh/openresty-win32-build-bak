local stringutil = require("utils.stringutil")

local function checkAuth(self, role)
  role = stringutil.isValidString(role) and role or "any"
  
  if not self.session.user or "table" ~= type(self.session.roles) then
    return false
  elseif "any" == role then 
    return true
  else 
    for k, v in pairs(self.session.roles) do
      if v == role then
        return true
      end
    end
    
    -- failed
    return false
  end
  
end

--
return function(self, role, redirect_to)
  local result
  local ok = checkAuth(self, role)
  if ok then
    result = stringutil.isValidString(redirect_to) and redirect_to or "home"
  else
    result = "login"
  end
  
  if result then 
    if self.route_name ~= result then
      self:write( { redirect_to = self:url_for(result) } )
    end
  else
    self:write( { "Forbidden", status = 403 } )
  end

end

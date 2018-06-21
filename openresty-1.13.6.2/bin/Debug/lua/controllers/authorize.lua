local stringutil = require("utils.stringutil")

local function checkAuth(self, role)
  role = stringutil.isValidString(role) and role or "any"
  return self.session.user and ("any" == role or self.session.role == role)
end

--
return function(self, role, redirect_to)
  local result
  local ok = checkAuth(self, role)
  if ok then
    result = stringutil.isValidString(redirect_to) and redirect_to or "welcome"
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

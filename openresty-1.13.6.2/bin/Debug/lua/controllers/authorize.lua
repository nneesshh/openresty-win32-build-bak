-- Localize
--local Users = require("models.Users")

--
return function(self, role)
  --return self.session.user and (nil == role or self.session.role == role)
  return true
end

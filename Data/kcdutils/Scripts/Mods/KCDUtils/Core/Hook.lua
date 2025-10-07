KCDUtils = KCDUtils or {}
KCDUtils.Hook = KCDUtils.Hook or {}

function KCDUtils.Hook.Method(tbl, methodName, wrapper)
  if not (tbl and type(tbl[methodName]) == "function" and type(wrapper) == "function") then return false end
  if not tbl["__orig_"..methodName] then
    tbl["__orig_"..methodName] = tbl[methodName]
  end
  local orig = tbl["__orig_"..methodName]
  tbl[methodName] = function(self, ...)
    return wrapper(orig, self, ...)
  end
  return true
end
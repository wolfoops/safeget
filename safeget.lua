--

local getter, setter = function(o,k)return o[k]end, function(o,k,v) o[k]=v end

local accessorMT = {
  __call = function(me,...)
      local n, key, newValue = select('#',...),...
      if rawget(me,'Error') then 
        return nil, rawget(me,'Error')
      elseif n==0 then -- as getter
        return rawget(me,'lastValue')
      elseif n>1 then -- as setter
        local lastValue = rawget(me,'lastValue')
        local ok = pcall(setter, lastValue, key, newValue)
        if ok then
          return true
        else
          return nil,string.format("safeGet: fail to set value <%s> into <%s> with key <%s>",
            tostring(newValue),tostring(lastValue),tostring(key))
        end        
      else
        error('safeGet: at least 2 parameters for setter usage.',2)
      end        
    end,
  __index = function(me,key)
      if not rawget(me,'Error') then
        local ok, ret = pcall(getter, rawget(me,'lastValue'), key)
        if not ok then
          rawset(me,'Error',string.format('safeGet: fail on accessing <%s> with key <%s>',
              tostring(rawget(me,'lastValue')), tostring(key)) )
        else
          rawset(me, 'lastValue', ret)
        end        
      end      
      return me
    end
}

local function safeGet(...)
  if select('#',...)==0 then error'safeGet: must has one parameter.' else
    return setmetatable({lastValue = ...},accessorMT)
  end  
end

if not arg then -- in a module
  return safeGet
end

--- test
local T = {A={B={C={D=123, S=9999}}}}

print('get 1:',safeGet(T).A.B.C.D())
print('set 2:',safeGet(T).A.B.C('D',456)) -- setter
print('get 3: ',safeGet(T).A.B.C.D())
print('get 4: ',safeGet(T).A.B.C.E())      -- return nil
print('get 5: ',safeGet(T).A.B.C.S.F())    -- return nil,error_message
print('set 6: ',safeGet(T).A.B.C('D'))     -- error on invalid setter usage




  

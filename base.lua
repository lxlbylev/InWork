local taskPath = system.pathForFile( "stats.json", system.DocumentsDirectory )
local accountPath = system.pathForFile( "user.json", system.DocumentsDirectory )
local usersPath = system.pathForFile( "users.json", system.DocumentsDirectory )
local json = require( "json" )

local round = function(num, idp)
  local mult = (10^(idp or 0))
  return math.floor(num * mult + 0.5) *(1/ mult)
end

local function CL(code)
  code = code:lower()
  code = code and string.gsub( code , "#", "") or "FFFFFFFF"
  code = string.gsub( code , " ", "")
  local colors = {1,1,1,1}
  while code:len() < 8 do
    code = code .. "F"
  end
  local r = tonumber( "0X" .. string.sub( code, 1, 2 ) )
  local g = tonumber( "0X" .. string.sub( code, 3, 4 ) )
  local b = tonumber( "0X" .. string.sub( code, 5, 6 ) )
  local a = tonumber( "0X" .. string.sub( code, 7, 8 ) )
  local colors = { r/255, g/255, b/255, a/255 }
  return colors
end

local function openFile(dir)
  local file = io.open( dir, "r" )
 
  local data
  if file then
    local contents = file:read( "*a" )
    io.close( file )
    data = json.decode( contents )
  end
  return data
end

local events = {list={},groups={}}

local function saveFile(data,dir)
  local file = io.open( dir, "w" )
 
  if file then
    file:write( json.encode( data ) )
    io.close( file )
  end
end

local function jsonForUrl(jsonString)
  jsonString = jsonString:gsub("{","%%7b")
  jsonString = jsonString:gsub("}","%%7d")
  jsonString = jsonString:gsub(",", "%%2c")
  jsonString = jsonString:gsub(",", "%%2c")
  jsonString = jsonString:gsub(",", "%%2c")
  jsonString = jsonString:gsub(":", "%%3a")
  jsonString = jsonString:gsub("%[", "%%5b")
  jsonString = jsonString:gsub("%]", "%%5d")

  jsonString = jsonString:gsub("=", "-")
  jsonString = jsonString:gsub("-", "%%3d")
  return jsonString
end

local a = math.random( 1000)
local base = {
  cx = round(display.contentCenterX),
  cy = round(display.contentCenterY),
  fullw  = round(display.actualContentWidth),
  fullh  = round(display.actualContentHeight),

  jsonForUrl = jsonForUrl,
  options = options,
  getConnection = function( path )
    local file = io.open( system.pathForFile( path..".json", system.DocumentsDirectory ), "r" )
    local data
    if file then
      data = file:read( "*a" )
      io.close( file )

    else
      print(path.." not found. Create new")
      local fileOrig = io.open( system.pathForFile( "data/"..path..".json", system.ResourceDirectory ), "r" )
      data = fileOrig:read( "*a" )

      local file = io.open( system.pathForFile( path..".json", system.DocumentsDirectory ), "w" )
 
      if file then
        file:write( data )
        io.close( file )
      end

    end 
    -- print("out",data)
    return data
  end,
  postConnection = function( path, val )
    local file = io.open( system.pathForFile( path..".json", system.DocumentsDirectory ), "w" )
 
    if file then
      file:write( json.encode( val ) )
      io.close( file )
    end
    return data
  end,

  CL = CL,
  div = function(num, hz)
    return num*(1/hz)-(num%hz)*(1/hz)
  end,
  getAngle = function(sx, sy, ax, ay)
    return (((math.atan2(sy - ay, sx - ax) *(1/ (math.pi *(1/ 180))) + 270) % 360))
  end,
  getCathetsLenght = function(hypotenuse, angle)
    angle = math.abs(angle*math.pi/180)
    local firstL = math.abs(hypotenuse*(math.sin(angle)))
    local secondL = math.abs(hypotenuse*(math.sin(90*math.pi/180-angle)))
    return firstL, secondL
  end,
  saveStats = function(infoTasks)
    saveFile(infoTasks, taskPath)
  end,
  loadStats = function()

    local infoTasks = openFile(taskPath)

    if ( infoTasks == nil or #infoTasks.levelStats == 0 ) then
      infoTasks = {lvl=1,levelStats={},xp=0, graf={} }
      for i=1, 1 do
        infoTasks.levelStats[i]={doneBestStep=false,doneBestCmd=false,done=false}
      end
      saveFile(infoTasks, taskPath)
    end
    return infoTasks
  end,
  saveLogin = function(account)
    saveFile(account, accountPath)
  end,
  loadLogin = function()

    local account = openFile(accountPath)

    if ( account == nil or account == {}) then
      account = {"",""}
      saveFile(account, accountPath)
    end
    return account
  end,
  saveUsers = function(users)
    saveFile(users, usersPath)
  end,
  loadUsers = function()
    local users = openFile(usersPath)

    if ( users == nil or #users == 0 ) then
      users = {
        [[{"id":"1","email":"user@gmail.com","name":"Софронов Александр Иннокентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
        [[{"id":"2","email":"worker@gmail.com","name":"Филиппов Егор Донатович","phonenumber":"","password":"12345678","working":"0","lic":"worker","plan":"VIP","signupdate":"3 May 2022","havejobdate":"{}"}]],
        [[{"id":"3","email":"admin@gmail.com","name":"Ершов Яков Лаврентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"1 May 2022","havejobdate":"{}"}]],
      }
      -- users = {
      --   [[{"id":"1","email":"alex@gmail.com","name":"Софронов Александр Иннокентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"2","email":"egor@gmail.com","name":"Филиппов Егор Донатович","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"3","email":"yakov@gmail.com","name":"Ершов Яков Лаврентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"VIP","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"4","email":"uriy@gmail.com","name":"Симонов Юрий Альвианович","phonenumber":"","password":"12345678","working":"0","lic":"worker","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"5","email":"mihail@gmail.com","name":"Владимиров Михаил Львович","phonenumber":"","password":"12345678","working":"0","lic":"worker","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"6","email":"bogdan@gmail.com","name":"Калашников Богдан Христофорович","phonenumber":"","password":"12345678","working":"0","lic":"admin","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      -- }
      saveFile(users, usersPath)
    end
    return users
  end,
  printJson = function(var)
    print(json.encode(var))
  end,
  event = {
    clearAll = function()
      events = {list={},groups={}}
    end, 
    add = function(name, butt, funcc)
      events.list[#events.list+1]=name
      events[name]={eventOn=false, but=butt, func=funcc}
    end,
    off = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          if event.eventOn==true then
            event.but:removeEventListener("tap", event.func)
          end
        end
      else
        local event = events[name]
        event.eventOn = enable or false
        event.but:removeEventListener("tap", event.func)
      end
    end,
    on = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          if event.eventOn==true then
            event.but:addEventListener("tap", event.func)
          end
        end
      else
        local event = events[name]
        events.eventOn = enable or true
        event.but:addEventListener("tap", event.func)
      end
    end,
    group = { 
      add = function(groupName,mas)
        if events[groupName]==nil then
          events.groups[#events.groups+1]=groupName
        end
        if type(mas)=="string" then
          if events[groupName]~=nil then
            events[groupName][#events[groupName]+1]=mas
          else
            events[groupName]={mas}
          end
        else
          events[groupName]=mas
        end
      end,
      on = function(groupName, enable)
        for i=1, #events[groupName] do
          local name = events[groupName][i]
          local event = events[name]
          events.eventOn = enable or true
          print(a.."#group "..groupName.." enable "..name)
          event.but:addEventListener("tap", event.func)
        end
      end,
      off = function(groupName, enable)
        for i=1, #events[groupName] do
          local name = events[groupName][i]
          local event = events[name]
          event.eventOn = enable or false
          event.but:removeEventListener("tap", event.func)
        end
      end,
    }

  },
  round = round,
  emitters = {laserShip = EMshipLfire}
  }
return base

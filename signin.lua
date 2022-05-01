--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]
local composer = require( "composer" )

local scene = composer.newScene()

-- local sqlite3 = require "sqlite3"
local myNewData 
local json = require( "json" )
local decodedData 
local accounts = {} 

-- local mime = require( "mime" )

local server
 
local backGroup, mainGroup, uiGroup

local q = require"base"

local firldsTable = {}

local c = {
	white = q.CL"FFFFFF",
	prewhite = q.CL"F9FAFB",
	ultrablack = q.CL"0E1111",
	black = q.CL"121515",
	gray = q.CL"1A1E1E",
	blue = q.CL"0058EE",
}
c.darkblue = {c.blue[1]*.9,c.blue[2]*.9,c.blue[3]*.9}
local function getSpaceWidth(font,fontSize)
	local label = display.newText( " ", -1000, -1000, font, fontSize )
	local w, h = label.width, label.height
	display.remove( label )
	return w, h
end

local function textWithLetterSpacing(options, space, anchorX)
	space = space*.01 + 1

	local j = 0
	local text = options.text 
	local width = 0
	local textGroup = display.newGroup()
	mainGroup:insert(textGroup)
	for i=1, #text:gsub('[\128-\191]', '') do
		local char = text:sub(i+j,i+j+1)
    local bytes = {string.byte(char,1,#char)}

    if bytes[1]==208 or bytes[1]==209 then -- for russian char
      char = text:sub(i+j,i+j+1)
      j=j+1
    else  -- for english char
      char = char:sub(1,1)
    end
		local charLabel = display.newText( textGroup, char, options.x+width, options.y, options.font, options.fontSize )
		charLabel.anchorX=0
		width = width + (charLabel.width-1.5)*space
	end
	if anchorX then
		textGroup.x = -width*(anchorX)
	end

end

local function createField( y, label, name, discription )

	local back = display.newRoundedRect(mainGroup, 50, y, q.fullw-50*2, 92, 6)
	back.fill = c.gray
	back.anchorX = 0

	-- local label = display.newText( {
	-- 	parent = mainGroup,
	-- 	text = label,
	-- 	x = 50,
	-- 	y = y-back.height*.5,
	-- 	font = "ubuntu_r.ttf",
	-- 	fontSize = 14*2,
	-- 	} )
	-- label.anchorX = 0
	-- label.anchorY = 1
	-- label.y = label.y - label.height
	
	textWithLetterSpacing({
		parent = mainGroup,
		text = label,
		x = 50,
		y = y-back.height*.5-48,
		font = "ubuntu_r.ttf",
		fontSize = 14*2,
		}, 10)



	local logField = native.newTextField(back.x+20, back.y, back.width-20, 90)
	mainGroup:insert( logField )
	logField.anchorX=0
	logField.isEditable=true
	logField.hasBackground = false
	logField.placeholder = discription
	logField.font = native.newFont( "ubuntu_r.ttf",16*2)
	logField:resizeHeightToFitFont()
	firldsTable[name] = logField
end
local incorrectLabel
local function showWarnin(text,time)
	time = time~=nil and time or 2000
	incorrectLabel.text=text
	incorrectLabel.alpha=1
	incorrectLabel.fill.a=1
	timer.performWithDelay( time, 
	function()
		transition.to(incorrectLabel.fill,{a=0,time=500} )
	end)
end
local function handleResponse( event )
 
    if ( event.isError)  then
    	print( "Network error: ", event.response )
		  -- showWarnin("Упс.. Что-то пошло не так")
		  showWarnin(tostring("Ошибка подкючения: "..event.response), 10000)
    else
      myNewData = event.response
    	decodedData = (json.decode(myNewData))
    	
    	if event.response~=nil and event.response=="wrong!!!" then
    		showWarnin("Неверная пара логин/пароль!")
    	elseif decodedData~=nil and decodedData~="" then
    		decodedData = decodedData[1]
    		for k, v in pairs(decodedData) do
	    		print(k,v)
	    	end
    		if decodedData==nil or decodedData=={} then print("Пустой реквест") return end
				print("pass corect")
				local stats = q.loadStats()

				stats.xp = tonumber(decodedData.xp)
				stats.lvl = tonumber(decodedData.currentLevel)



				local statsOnID = {} --приходят айди а не нум уровня, далее в меню находится нум уровння
    		local text = decodedData.passedLevelIDS.." "
				local passedLevels = {}

				local levelWithDates = {}
				for v in text:gmatch("%d+%.%d%d%d%d%.%d%d%.%d%d*") do
					local date = (v:sub(v:find("%.")+1,-1)):gsub("%.","-")
					local lvl = tonumber(v:sub(1,v:find("%.")-1))
					if levelWithDates[date]~=nil then
						levelWithDates[date][#levelWithDates[date]+1] = lvl
					else
						levelWithDates[date] = {lvl}
					end
					print(v:sub(v:find("%.")+1,-1), "is", lvl)
					passedLevels[#passedLevels+1] = v:sub(0,v:find("%.")-1)
				end
				stats.graf = levelWithDates
				q.saveStats(stats)
				-- print("+++",text)
				for v in text:gmatch("%d+%.%d ") do
					passedLevels[#passedLevels+1] = v
					-- print("vdd",v)
					-- print("++++++++++++++++++++++++++=")
				end
				for i=1, #levelWithDates do
					print(i.."#",levelWithDates[i])
				end
				print("=")
				for i=1, #passedLevels do
					print(i.."#",passedLevels[i])
				end
			
				local tasks = {"doneBestStep","doneBestCmd"}
				for i=1, #passedLevels do
					local thisNum = passedLevels[i]
					print(thisNum)

					if thisNum:find("%.") then
						print("with .")
						local first = tostring(thisNum:sub(1,thisNum:find("%.")-1))
						print(thisNum)

						local last = tonumber(thisNum:sub(thisNum:find("%.")+1,-1))
						print(first,last)
						-- print("ID:"..first)
						-- print("TASK:"..last)
						if statsOnID[first]==nil then statsOnID[first]={} end  
						statsOnID[first][tasks[last]] = true
					else
						if statsOnID[tostring(passedLevels[i])]==nil then statsOnID[tostring(passedLevels[i])]={} end  
						print("without")
						print("level #"..passedLevels[i].." is done")
						statsOnID[tostring(passedLevels[i])].done = true
					end
				end
				composer.setVariable( "levelsIDStats", statsOnID )
			


				




				q.saveLogin({decodedData.email,decodedData.password,server})
				composer.gotoScene( "menu" )
				composer.removeScene( "signin" )



	    	-- for i=1, #decodedData do
	    		-- accounts[i] = {decodedData[i].email,decodedData[i].password}
	    		-- print(decodedData[i].email)
	    		-- print(decodedData[i].password)
    		-- end
	    end
    	

    	-- [[[{"id":"1","name":"neoko","email":"wotacc0809@gmail.com","email_verified_at":null,"password":"$2y$10$QJyVqgRGSr3jMxZytttME.cd6wU23WqPc\/F7I275zFsU9JnHE\/56e","remember_token":"dkeooNuuuxtC3MIkWv7yU52lvQ3SN8bUewNT92tfHEyKBxWQgkgtSmqtDtq9","created_at":"2022-04-25 01:29:28","updated_at":"2022-04-25 01:29:28"},{"id":"2","name":"lxl","email":"jopa@mama.com","email_verified_at":null,"password":"$2y$10$MkzjisTLAwC3c8z4J7mzM.bwDOwvtadLWCRM2VkdvgNaV2HXlj942","remember_token":null,"created_at":"2022-04-25 01:53:52","updated_at":"2022-04-25 01:53:52"}]]]
    	-- q.saveLogin(decodedData)
    end
     
    return
end

local function validemail(str)
  if str == nil then return nil end
  if str:len() == 0 then return nil, "Введите почту" end
  if (type(str) ~= 'string') then
    error("Expected string")
    return nil
  end
  if not str:find("%@.") then 
    return nil, "Часть после @ некорректна!"
  end
  local lastAt = str:find("[^%@]+$")
  local localPart = str:sub(1, (lastAt - 2)) -- Returns the substring before '@' symbol
  local domainPart = str:sub(lastAt, #str) -- Returns the substring after '@' symbol
  -- we werent able to split the email properly
  if localPart == nil then
    return nil, "Часть до @ некорректна!"
  end

  if domainPart == nil or not domainPart:find("%.") then
    return nil, "Часть после @ некорректна!"
  end
  if string.sub(domainPart, 1, 1) == "." then
    return nil, "Первый символ не может быть точкой!"
  end
  -- local part is maxed at 64 characters
  if #localPart > 64 then
    return nil, "Часть до @ должна быть меньше 64симв.!"
  end
  -- domains are maxed at 253 characters
  if #domainPart > 253 then
    return nil, "Часть после @ должна быть меньшк 253симв.!"
  end
  -- somthing is wrong
  if lastAt >= 65 then
    return nil, "Что-то не так..."
  end
  -- quotes are only allowed at the beginning of a the local name
  local quotes = localPart:find("[\"]")
  if type(quotes) == 'number' and quotes > 1 then
    return nil, "Неправильно расположены кавычки!"
  end
  -- no @ symbols allowed outside quotes
  if localPart:find("%@+") and quotes == nil then
    return nil, "Слишком много @!"
  end
  -- no dot found in domain name
  if not domainPart:find("%..") then
    return nil, "Нет .com/.ru части!"
  end
  -- only 1 period in succession allowed
  if domainPart:find("%.%.") then
    return nil, "Две точки подряд после @!"
  end
  if localPart:find("%.%.") then
    return nil, "Две точки подряд до @!"
  end
  -- just a general match
  if not str:match('[%w]*[%p]*%@+[%w]*[%.]?[%w]*') then
    return nil, "Проверка валидности почты провалена!"
  end
  -- all our tests passed, so we are ok
  return true
end

local submitButton
local function submitFunc(event)
	submitButton.fill = q.CL"4d327a"
	local r,g,b = unpack( c.darkblue )
	timer.performWithDelay( 400, 
	function()
		transition.to(submitButton.fill,{r=r,g=g,b=b,time=300} )
	end)

	local mail, pass = firldsTable.mail.text, firldsTable.pass.text
	local allows, errorMail = validemail(mail)
	if not allows then
		showWarnin(errorMail)
	elseif #pass==0 then
		showWarnin("Введите пароль")
	elseif #pass<8 then
		showWarnin("Пароль от 8 символов")
	elseif allows then
		
		-- composer.setVariable( "ip", ip )
		-- server = ip
		-- composer.gotoScene( "menu" )
		-- composer.removeScene( "signin" )
		
		print("REQUEST")
		local notReadyJson = json.encode( {} )
    local jsonString = q.jsonForUrl(notReadyJson)
    local name = "five"
    local taskStep = "1"
    local taskCmd = "2"
    network.request( "http://127.0.0.1/dashboard/remembertoken.php?level="..jsonString.."&levelName="..name.."&xpCount=15&tasks="..taskStep.." "..taskCmd, "GET", networkListener, {body = "1233siohbiubik33"} )
		-- network.request( "https://"..server.."/alihack/public/passwordCheck?email=" .. login .. "&password=".. pass, "GET", handleResponse, getParams )
		-- network.request( "https://"..server.."/alihack/public/passwordCheck?email=" .. login .. "&password=".. pass, "GET", handleResponse, getParams )
		-- print("https://"..server.."/alihack/public/passwordCheck?email=" .. login .. "&password=".. pass)
		-- network.request( "https://google.com", "GET", handleResponse )
		-- network.request( server.."/alihack/public/passwordCheck?email=denchik69150@gmail.com&password=12345678", "GET", handleResponse, getParams )
	end
end

local logField, pasField, ipField
function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	server = composer.getVariable( "ip" )

	local back = display.newRect(backGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.black


	local backTop = display.newRect(backGroup,q.cx,0,q.fullw,440)
	backTop.anchorY = 0
	backTop.fill = c.ultrablack


	local backLogo = display.newRoundedRect( mainGroup, q.cx, backTop.height*.5, 180, 180, 14*2 )
	backLogo.fill = c.gray

	local labelSignIn = display.newText( {
		parent = mainGroup,
		text = "Вход",
		x = 50,
		y = 440+100,
		font = "ubuntu_b.ttf",
		fontSize = 24*2,
		} )
	labelSignIn.anchorX = 0

	local labelDiscription = display.newText( {
		parent = mainGroup,
		text = "Войдите в аккаунт",
		x = 50,
		y = 440+100+80,
		font = "ubuntu_r.ttf",
		fontSize = 16*2,
		} )
	labelDiscription.anchorX = 0

	-- textWithLetterSpacing({
	-- 	parent = mainGroup,
	-- 	text = "Войдите в аккаунт",
	-- 	x = 50,
	-- 	y = 480+100+80,
	-- 	font = "ubuntu_r.ttf",
	-- 	fontSize = 16*2,
	-- 	}, 0)

	-- textWithLetterSpacing({
	-- 	parent = mainGroup,
	-- 	text = "Войдите в аккаунт",
	-- 	x = 50,
	-- 	y = 520+100+80,
	-- 	font = "ubuntu_r.ttf",
	-- 	fontSize = 16*2,
	-- 	}, 20)
	

	createField( 1120-240, "ПОЧТА", "mail", "Введите почту" )
	firldsTable.mail.inputType = "email"
	createField( 1120, "ПАРОЛЬ","pass", "Введите пароль" )
	firldsTable.pass.isSecure = true
	firldsTable.pass.inputType = "no-emoji"

	submitButton = display.newRoundedRect(mainGroup, 50, q.fullh-50, q.fullw-50*2, 92, 6)
	submitButton.anchorX=0
	submitButton.anchorY=1
	submitButton.fill = c.blue

	local labelContinue = textWithLetterSpacing( {
		parent = mainGroup, 
		text = "ВОЙТИ", 
		x = submitButton.x+submitButton.width*.5, 
		y = submitButton.y-submitButton.height*.5, 
		font = "ubuntu_b.ttf", 
		fontSize = 14*2
		}, 10, .5)

	local label = display.newText( {
		parent = mainGroup, 
		text = "Забыли пароль?",
		x = 60,
		y = (1120)+100, 
		font = "ubuntu_b.ttf", 
		fontSize = 16*2
		})
	label.alpha = .5
	label.anchorX=0

	-- local label = display.newText( {
	-- 	parent = mainGroup, 
	-- 	text = "AAAЗабыли пароль?",
	-- 	x = 60,
	-- 	y = (1120)+150, 
	-- 	font = "ubuntu_r.ttf", 
	-- 	fontSize = 16*2
	-- 	})
	-- label.alpha = .5
	-- label.anchorX=0

	-- local logo = display.newImageRect(mainGroup, "logo.png",300, 351)
	-- logo.x = q.cx
	-- logo.y = 301


	incorrectLabel = display.newText( {
		parent = uiGroup, 
		text = "Неверная пара логин/пароль!", 
		x = 60, 
		y = 1280,
		width = q.fullw - 60*2, 
		font = "roboto_r.ttf", 
		fontSize = 37})
	incorrectLabel:setFillColor( unpack( q.CL"e07682") )
	incorrectLabel.anchorX=0
	incorrectLabel.anchorY=0
	incorrectLabel.alpha=0

	-- local version = system.getInfo("appVersionString")
	-- local versionLabel = display.newText( uiGroup, "version: "..version, 20, q.fullh, "roboto_r.ttf", 35)
	-- versionLabel.anchorX=0
	-- versionLabel.anchorY=1
	-- if version:sub(1,1)=="0" then
	-- 	versionLabel.text = versionLabel.text.." beta"
	-- end

	local regLabel = display.newText( {
		parent = mainGroup, 
		text = "Нет аккаунта?",
		x = labelDiscription.x,
		y = labelDiscription.y+60, 
		font = "ubuntu_b.ttf", 
		fontSize = 16*2
		})
	regLabel.alpha = .5
	regLabel.anchorX=0

	-- firldsTable.ip.text="192.168.0.1"
	-- firldsTable.login.text="denchik69150@gmail.com"
	-- firldsTable.pass.text="12345678"

	regLabel:addEventListener( "tap", function()
		for k,v in pairs(firldsTable) do
			firldsTable[k].x = -q.fullw
		end
		timer.performWithDelay( 1,function()
			composer.gotoScene("signup")
		end )
	end )
	submitButton:addEventListener( "tap", submitFunc )

end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		local accountInfo = q.loadLogin()
		if accountInfo[1]~="" then
			print(accountInfo[1])
			composer.setVariable( "ip", accountInfo[3] )
			composer.gotoScene( "menu" )
			composer.removeScene( "signin" )
		end

		for k,v in pairs(firldsTable) do
			firldsTable[k].x = 70
		end
	elseif ( phase == "did" ) then
		

		-- timer.performWithDelay( 1,function()
		-- 	composer.gotoScene("signup")
		-- end )
	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		
	elseif ( phase == "did" ) then

	end
end


function scene:destroy( event )

	local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene

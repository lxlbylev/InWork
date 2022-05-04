--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]
local composer = require( "composer" )

local scene = composer.newScene()
local isDevice = (system.getInfo("environment") == "device")

-- local sqlite3 = require "sqlite3"
local myNewData 
local json = require( "json" )
local decodedData 
local accounts = {} 

-- local mime = require( "mime" )

local server
 
local backGroup, mainGroup, finishGroup

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

local c = {
	white = q.CL"000000",
	prewhite = q.CL"F9FAFB",
	ultrablack = q.CL"CCCCCC",
	black = q.CL"FFFFFF",
	gray = q.CL"DEDEDE",
	blue = q.CL"0058EE",
	outline = q.CL"9F9F9F",
}

local function getSpaceWidth(font,fontSize)
	local label = display.newText( " ", -1000, -1000, font, fontSize )
	local w, h = label.width, label.height
	display.remove( label )
	return w, h
end

local function textWithLetterSpacing(options, space, anchorX)
	space = space*.01 + 1
	if options.color==nil then options.color={1,1,1} end

	local j = 0
	local text = options.text 
	local width = 0
	local textGroup = display.newGroup()
	options.parent:insert(textGroup)
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
		charLabel:setFillColor( unpack(options.color) )
	end
	if anchorX then
		textGroup.x = -width*(anchorX)
	end
	return textGroup
end

local function createField( y, label, name, discription )

	local back = display.newRoundedRect(mainGroup, 50, y, q.fullw-50*2, 92, 6)
	back.fill = c.gray
	back.anchorX = 0

	
	textWithLetterSpacing({
		parent = mainGroup,
		text = label,
		x = 50,
		y = y-back.height*.5-48,
		font = "ubuntu_r.ttf",
		fontSize = 14*2,
		color = c.white,
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
	print("set text:"..text)
	incorrectLabel.text=text
	incorrectLabel.alpha=1
	incorrectLabel.fill.a=1
	timer.performWithDelay( time, 
	function()
		transition.to(incorrectLabel.fill,{a=0,time=500} )
	end)
end

local finished = false
local function hideMain()
	finished = true
	mainGroup.alpha = 0
	finishGroup.alpha = 1
	firldsTable.email:removeSelf( )
	for k,v in pairs(firldsTable) do
		print(k,v)
		firldsTable[k].x = -q.fullw
		firldsTable[k]:removeSelf( )
		v:removeSelf( )
	end
end
local function handleResponse( event )
 
    if ( event.isError)  then
    	print( "Network error: ", event.response )
		  showWarnin(tostring("Ошибка подкючения: "..event.response), 10000)
    else
    	local myNewData = event.response
      if myNewData=="Register done!\n\n\n" then
				hideMain()
		  else
		  	print(myNewData)
		  	print(json.encode(myNewData))
		  	showWarnin("Упс.. Что-то пошло не так")
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
    return nil, "Введите почту"
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
	if finished then
		composer.gotoScene("signin")
		return
	end
	submitButton.fill = q.CL"4d327a"
	local r,g,b = unpack( c.blue )
	timer.performWithDelay( 400, 
	function()
		transition.to(submitButton.fill,{r=r,g=g,b=b,time=300} )
	end)

	local email, pass, name = firldsTable.email.text, firldsTable.pass.text, firldsTable.name.text
	print(email, pass, name)
	local allows, errorMail = validemail(email)
	if not allows then
		showWarnin(errorMail and errorMail or "mail")
	elseif #pass==0 then
		showWarnin("Введите пароль")
	elseif #pass<8 then
		showWarnin("Пароль от 8 символов")
	elseif allows then
		if name~="" then name = "&name="..name end
		local time = os.date("!*t",os.time())
		time = time.day.." "..os.date("%B",os.time()).." "..time.year
		print("REQUEST")
		network.request( "http://127.0.0.1/dashboard/register.php?email="..email.."&password="..pass.."&date="..time..name, "GET", handleResponse )
	else
		showWarnin("dwwd символов")
	end
end

local logField, pasField, ipField
function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

	finishGroup = display.newGroup()
	sceneGroup:insert(finishGroup)
	finishGroup.alpha = 0

	server = composer.getVariable( "ip" )

	local back = display.newRect(backGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.black


	local backTop = display.newRect(backGroup,q.cx,0,q.fullw,440)
	backTop.anchorY = 0
	backTop.fill = c.ultrablack


	local backLogo = display.newRoundedRect( backGroup, q.cx, backTop.height*.5, 180, 180, 14*2 )
	backLogo.fill = c.gray

	local labelSignIn = display.newText( {
		parent = mainGroup,
		text = "Регистрация",
		x = 50,
		y = 440+100,
		font = "ubuntu_b.ttf",
		fontSize = 24*2,
		} )
	labelSignIn.anchorX = 0
	labelSignIn.fill = c.white

	local labelDiscription = display.newText( {
		parent = mainGroup,
		text = "Создайте свой аккаунт",
		x = 50,
		y = 440+100+80,
		font = "ubuntu_r.ttf",
		fontSize = 16*2,
		} )
	labelDiscription.anchorX = 0
	labelDiscription.fill = c.white


	createField( 1120-240, "ПОЧТА", "email", "Введите почту" )
	firldsTable.email.inputType = "email"
	createField( 1120-50, "ПАРОЛЬ","pass", "Введите пароль" )
	firldsTable.pass.inputType = "no-emoji"

	createField( 1120+240-100, "ФИО","name", "Фамалия Имя Отчество" )


	submitButton = display.newRoundedRect(backGroup, 50, q.fullh-50, q.fullw-50*2, 92, 6)
	submitButton.anchorX=0
	submitButton.anchorY=1
	submitButton.fill = c.blue


	local labelContinue = textWithLetterSpacing( {
		parent = mainGroup, 
		text = "РЕГИСТРАЦИЯ", 
		x = submitButton.x+submitButton.width*.5, 
		y = submitButton.y-submitButton.height*.5, 
		font = "ubuntu_b.ttf", 
		fontSize = 14*2
		}, 10, .5)

	local label = display.newText( {
		parent = mainGroup, 
		text = "Уже есть аккаунт?",
		x = 60,
		y = 1120+240-20, 
		font = "ubuntu_b.ttf", 
		fontSize = 16*2
		})
	label:setFillColor( unpack(c.white) )
	label.alpha = .5
	label.anchorX=0


	incorrectLabel = display.newText( {
		parent = mainGroup, 
		text = "Неверная пара логин/пароль!", 
		x = 60, 
		y = 1500,
		width = q.fullw - 60*2, 
		font = "roboto_r.ttf", 
		fontSize = 37})
	incorrectLabel:setFillColor( unpack( q.CL"e07682") )
	incorrectLabel.anchorX=0
	incorrectLabel.anchorY=0
	incorrectLabel.alpha=0


	local labelSucess = display.newText( {
		parent = finishGroup,
		text = "Регистрация завершена",
		x = 50,
		y = 440+100,
		font = "ubuntu_b.ttf",
		fontSize = 24*2,
		} )
	labelSucess.anchorX = 0
	labelSucess:setFillColor(unpack(c.white))

	local labelDiscription = display.newText( {
		parent = finishGroup,
		text = "Теперь для можете входить в аккаунт",
		x = 50,
		y = 440+100+80+20,
		width = q.fullw-120,
		font = "ubuntu_r.ttf",
		fontSize = 16*2,
		} )
	labelDiscription.anchorX = 0
	labelDiscription:setFillColor(unpack(c.white))

	local labelContinue = textWithLetterSpacing( {
		parent = finishGroup, 
		text = "ОК", 
		x = submitButton.x+submitButton.width*.5, 
		y = submitButton.y-submitButton.height*.5, 
		font = "ubuntu_b.ttf", 
		fontSize = 14*2
		}, 10, .5)


	firldsTable.email.text = "admin@gmail.com"
	firldsTable.pass.text = "12345678"
	firldsTable.name.text = "Lev Love Lol"


	label:addEventListener( "tap", function()
		for k,v in pairs(firldsTable) do
			display.remove(firldsTable[k])
		end
		timer.performWithDelay( 1, function()
			composer.gotoScene("signin")
		end )
	end )
	submitButton:addEventListener( "tap", submitFunc )
end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		
		-- hideMain()
	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		
	elseif ( phase == "did" ) then
		composer.removeScene("signup")
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

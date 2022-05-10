--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]
local composer = require( "composer" )

local scene = composer.newScene()
local isDevice = true--(system.getInfo("environment") == "device")


local backGroup

local mainGroup, testsGroup, quizzScreen, quizzGame, kursesGroup, kursScreen, kursGroup 
local eventGroup
local chatGroup
local profileGroup, adminGroup

local uiGroup


local json = require( "json" )
local q = require"base"
local server


local c = {
	black = q.CL"000000",
	gray = q.CL"808080",
	gray2 = q.CL"DEDEDE",
	grayButtons = q.CL"ADB5BD",
	prewhite = q.CL"F9FAFB",
	ultrablack = q.CL"CCCCCC",
	blue = q.CL"0058EE",
	outline = q.CL"9F9F9F",
	white = q.CL"FFFFFF",
}

local mainLabel
local selected = false
local searchField

local news = {
	{title = "Профориетация \"технологическая\"",date = "03 мая, 2022"},
	{title = "Проф. тест по гуманитарным наукам",date = "03 мая, 2022"},
	{title = "Проф. пригодность",date = "03 мая, 2022"},
}

local scrollInfo = {test={cancel=false,maxDown=0,maxUp=0},news={cancel=false,maxDown=0,maxUp=0}}
local function scroll(event)
  local phase = event.phase
  local scrollingGroup = event.target

  local tag = event.target.scrolltag
  local maxUp, maxDown = scrollInfo[tag].maxUp, scrollInfo[tag].maxDown
  display.currentStage:setFocus( scrollingGroup )

  if ( "began" == phase ) then
    if event.y>(q.fullh-125) or event.y<330 then scrollInfo[tag].cancel = true display.currentStage:setFocus( nil ) return end
    scrollInfo[tag].cancel = false
    scrollingGroup.mouseY = event.y
    scrollingGroup.oldposY = scrollingGroup.y
  elseif ( "moved" == phase ) then
    if scrollInfo[tag].cancel then return end
    if scrollingGroup.mouseY and scrollingGroup.oldposY then
        
      -- print(event.y-scrollingGroup.mouseY)
      local thisY = event.y-scrollingGroup.mouseY
      if (thisY>maxDown) and scrollingGroup.y>maxDown then 
        scrollingGroup.y = maxDown
        display.currentStage:setFocus( nil )
        scrollInfo[tag].cancel = true
        return 
      elseif (thisY<maxDown) and scrollingGroup.y<maxUp then 
        scrollInfo[tag].cancel = true
        scrollingGroup.y = maxUp
        display.currentStage:setFocus( nil )
        return
      end

      scrollingGroup.y = scrollingGroup.oldposY+thisY
    else
      display.currentStage:setFocus( nil )
    end
  elseif ( "ended" == phase or "cancelled" == phase ) then
    timer.performWithDelay( 10, 
    function() 
      if type(scrollingGroup.y)~="number" then return end
      if scrollingGroup.y>maxDown then 
        scrollingGroup.y = maxDown
      elseif scrollingGroup.y<maxUp then 
        scrollingGroup.y = maxUp
      end
    end)
    display.currentStage:setFocus( nil )
  end
  return true
end

local nowScene = "menu"


local mainButton, eventButton, chatButton, profileButton
local graf
local quizzGame, quizzCreate
local closePCMenu = function() end
local closeCN = function() end
local function hideLayer(toScene)

  if nowScene==toScene then return end
	timer.performWithDelay( 1, function()
    print("hiding from "..nowScene.." to "..toScene)
    native.setKeyboardFocus( nil )
    if nowScene == "test" then
      q.event.group.on("testsButtons")
      mainLabel.alpha = 1
      display.remove(quizzGame) quizzGame=nil
    elseif nowScene == "kurs" then
      q.event.group.on("downBar")
      q.event.group.on("kursesButtons")
      mainLabel.alpha = 1
      mainGroup.alpha = 1
      display.remove(kursGroup) kursGroup=nil
		elseif nowScene == "menu" then

	  	mainButton:setFillColor( unpack( c.grayButtons ) )
			searchField.x = -1000
			searchField.y = -1000
			timer.performWithDelay( 1, function()
				mainGroup.alpha = 0
			end )
		elseif nowScene == "profile" then
			profileGroup.alpha = 0
	  	profileButton:setFillColor( unpack( c.grayButtons ) )
      closePCMenu()
		elseif nowScene == "chat" then
			chatGroup.alpha = 0
	  	chatButton:setFillColor( unpack( c.grayButtons ) )
		elseif nowScene == "event" then
			eventGroup.alpha = 0
	  	eventButton:setFillColor( unpack( c.grayButtons ) )
      closeCN()
    elseif nowScene == "admin" then
      adminGroup.alpha = 0
      display.remove(graf)
		end
    nowScene = toScene
	end )
end 

local function toMain()
	hideLayer("menu")
	timer.performWithDelay( 2, function()
		mainLabel.text = "Навигация"
		mainGroup.alpha = 1
		mainButton:setFillColor( unpack( c.blue ) )
		searchField.x = searchField.pos.x
		searchField.y = searchField.pos.y
	end )
end

local function toEvent()
	hideLayer("event")
	timer.performWithDelay( 2, function()
		mainLabel.text = "События"
	  eventButton:setFillColor( unpack( c.blue ) )
		eventGroup.alpha = 1
	end )
end

local function toChat()
	hideLayer("chat")
	timer.performWithDelay( 2, function()
		mainLabel.text = "Чат"
	  chatButton:setFillColor( unpack( c.blue ) )
		chatGroup.alpha = 1
	end )
end

local function toAccount()
	hideLayer("profile")
	timer.performWithDelay( 2, function()
		nowScene = "profile"
		mainLabel.text = "Профиль"
	  profileButton:setFillColor( unpack( c.blue ) )
		profileGroup.alpha = 1
	end )
end

-- --
local citc
local function genCircle(realPercent, x, y, left)
    if graf~=nil then display.remove(graf) end
    graf = display.newGroup()
    adminGroup:insert( graf )
    local dlin = 200
    graf.x = x
    graf.y = y-dlin*2
    graf.xScale = 2
    graf.yScale = 2
    local realPercent = realPercent
    if realPercent==75 then realPercent=74
    elseif realPercent==100 then realPercent=99 end
    local percent = (360/100) * realPercent
    local tochka = display.newCircle( graf, 0, dlin, dlin/2 )
    tochka.fill = c.gray2
    -- tochka.alpha = .5
    
    local plan
    if realPercent>50 then
      plan = {0,-dlin}
      -- print("min")
    else
      plan = {0,0, 0,-dlin}
    end
    for i=1, 3 do

      if realPercent>25*i then
        local gradus = (360/100) *(25*i)
        local x, y = q.getCathetsLenght(dlin, gradus%180 )
        if gradus>180 then
          x = -x
        end
        plan[#plan+1] = x
        plan[#plan+1] = y
        -- print("add ",x,y)
      end
      if realPercent<=25*i or i==3 then
        local x, y = q.getCathetsLenght(dlin, percent)
        if percent>180 then
          x = -x
        end
        if percent>180+90 or percent<360*.25  then
          y = -y
        end
        plan[#plan+1] = x
        plan[#plan+1] = y
        -- print("end ",x,y)
        break 
      end
    end
    if percent>180 then
      plan[#plan+1] = 0
      plan[#plan+1] = 0
    end
    citc = display.newPolygon( graf, 0, 0, plan )
    citc.fill = c.blue
    citc.anchorY = 0

    if realPercent<50 then -- до 50
      citc.anchorX = 0
    elseif realPercent<75 then -- после 50
      -- print(citc.width-dlin,dlin*2)
      local slevaDop = citc.width-dlin
      local all = dlin*2
      citc.anchorX = ((slevaDop)/(citc.width))
      -- print(citc.anchorX,"anchorX")
    elseif realPercent<100 then -- после 75
      citc.anchorX = .5
    end
    local mask = display.newImageRect( graf, "img/maskx4.png", dlin*2, dlin*2 )
    mask.x, mask.y = 0, dlin
    graf:toBack( )
    if left then
      graf.xScale = -2
      tochka.fill = c.blue
      citc.fill = c.gray2
    end
end

local grafScreen
local statGraf
local function closeGraf(event)
  print("closeGraf")
  display.remove(grafScreen) grafScreen=nil
  display.remove(quizzGame) quizzGame=nil
  if event.target.name=="Tasks" then
    timer.performWithDelay( 1, function()
      q.event.group.on("levelsButtons")
      q.event.group.on("kursesButtons")
    end)
  end
end
local function getDay(num)
  local today = os.date("*t",os.time()+num*60*60*24)
  local month, day = today.month, today.day
  if tonumber(month)<10 then month = "0"..month end
  if tonumber(day)<10 then day = "0"..day end
  local todayString = today.year.."-"..month.."-"..day
  return todayString, today.day
end
local function openGraf()
  print("shhow")
  if grafScreen~=nil then return end
  -- display.remove(quizzGame) quizzGame=nil
  -- q.event.group.off("levelsButtons")
  grafScreen = display.newGroup()
  adminGroup:insert( grafScreen )
  -- grafScreen:toBack()

  local xPos = {}
  local yPos = {}
  local dates = {}
  local now
  for i=1, 7 do
    local a = display.newRect(grafScreen, q.fullw/8*i+40,q.fullh-240,30,30)
    a.fill=q.CL"75c8f0"
    xPos[i]=a.x
    local allDate, day = getDay(-7+i)
    dates[i] = allDate
    local dayLabel = display.newText(grafScreen, day, q.fullw/8*i+40,q.fullh-190, "roboto_r.ttf", 44)
    dayLabel:setFillColor( 0 )
  end
  for i=0, 6 do
    local a = display.newRect(grafScreen, 70,q.fullh-210-q.fullw/8*(i+1),q.fullw/8*7-30,5)
    yPos[i]=a.y
    a.anchorX=0
    a.fill={.7}
    local b = display.newRect(grafScreen, a.x,a.y,30,30)
    b.fill=q.CL"8568b5"
    local cataLabel = display.newText(grafScreen, i, a.x-40, a.y, "roboto_r.ttf", 44)
    cataLabel:setFillColor( 0 )
  end
  
  -- stats = event.response
  
  local points = {}
  for i=1, #dates do
    print(dates[i])
    if statGraf[dates[i]]~=nil then
      local j = statGraf[dates[i]]
      j = j<7 and j or 6
      local a = display.newCircle(grafScreen, xPos[i], yPos[j], 15, 20)
      a.fill=q.CL"9ff594"
      points[#points+1]=a.x
      points[#points+1]=a.y
    else
      local a = display.newCircle(grafScreen, xPos[i], yPos[0], 15, 20)
      a.fill=q.CL"9ff594"
      points[#points+1]=a.x
      points[#points+1]=a.y
    end
  end
  local line = display.newLine(grafScreen, unpack(points) )
  line:setStrokeColor( unpack(q.CL"9ff594") )
  line.strokeWidth = 8
end

local statistic, notWorkingLabel, workingLabel
local function toAdmin()
  hideLayer("admin")
  timer.performWithDelay( 2, function()
    mainLabel.text = "Администрирование"
    -- profileButton:setFillColor( unpack( c.blue ) )
    
    -- statistic = 25
    local thisStat = statistic
    thisStat = thisStat == 0 and 1 or thisStat

    if statistic>(50+12.5) then
      notWorkingLabel.y = 110
      workingLabel.y = 300
    else
      notWorkingLabel.y = 370
      workingLabel.y = 180
    end
    local i = 0
    timer.performWithDelay( 150/30, function()
      i = i + 1
      display.remove(citc)
      genCircle(i, 180, 240, false) 
    end, thisStat )
    adminGroup.alpha = 1
    openGraf()

  end )
end
-- -- --
local navMenuNow = "tests"
local selectedRect
local usLabel, vacLabel
local function toKurs()
  if navMenuNow == "kurs" then return end
  navMenuNow = "kurs"
  testsGroup.alpha = 0
  kursesGroup.alpha = 1
  transition.to(selectedRect,{x=q.cx,time=500, transition=easing.inOutBack })
  usLabel.fill = c.gray
  vacLabel.fill = {0,0,0}
end
local function toTests()
  if navMenuNow == "tests" then return end
  navMenuNow = "tests"
  testsGroup.alpha = 1
  kursesGroup.alpha = 0
  transition.to(selectedRect,{x=0,time=300, transition=easing.inOutBack})
  vacLabel.fill = c.gray
  usLabel.fill = {0,0,0}
end

-- -- --

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

local function createButton(group,label,y, name)
	local submitButton = display.newRoundedRect(group, 50, y, q.fullw-50*2, 100, 6)
	submitButton.anchorX=0
	submitButton.anchorY=1
	submitButton.fill = c.blue

	local labelContinue = textWithLetterSpacing( {
		parent = group, 
		text = label, 
		x = submitButton.x+submitButton.width*.5, 
		y = submitButton.y-submitButton.height*.5, 
		font = "ubuntu_b.ttf", 
		fontSize = 14*2
		}, 10, .5)

  return submitButton, labelContinue
end





local function jsonForUrl(val)
  return q.jsonForUrl( json.encode( val ) )
end


local function sendQuizz(name, quizz)
  if name==nil then name = quizz.title end
  local quests = jsonForUrl( quizz.questions )
  local answers = jsonForUrl( quizz.answers )
  local praises = jsonForUrl( quizz.praises )
  -- print(server)
  -- print("http://"..server.."/dashboard/testUpload.php?title="..name.."&questions="..quests.."&answers="..answers.."&praises"..praises)
  network.request( "http://"..server.."/dashboard/testUpload.php?title="..name.."&questions="..quests.."&answers="..answers.."&praises="..praises, "GET" )

end


local allQuizz = {}
local topMain


local quizzInfo = {}
local function startQuizz(event)
  if event.y>(q.fullh-125) or event.y<330 then return end
  q.event.group.off("testsButtons")
  searchField.x = -1000
	searchField.y = -1000

  quizzInfo = allQuizz[event.target.i]
  mainLabel.alpha = 0


  -- if quizzScreen==nil then quizzScreen = display.newGroup() uiGroup:insert(quizzScreen) quizzScreen:toBack( ) end
  -- local quizzGame = quizzScreen
  hideLayer("test")
  if quizzGame ~=nil then display.remove(quizzGame) end
  quizzGame = display.newGroup()
  quizzScreen:insert( quizzGame )

  local backGround = display.newRect(quizzGame, q.cx, q.cy, q.fullw, q.fullh)
  backGround.fill={.95}

  local grayBack = display.newRect( quizzGame, q.cx, 0, q.fullw, 370 )
  grayBack.anchorY=0
  grayBack.fill = {0}
  grayBack.alpha = .15

  local testwarnLabel = display.newText({
    parent = quizzGame,
    text = "Каркас теста.\nДизайн в разработке",
    x=30,
    y=100,
    font="roboto_r.ttf",
    align="left",
    fontSize=24*2,
  })
  testwarnLabel:setFillColor( 1 )
  testwarnLabel.anchorX=0
  testwarnLabel.anchorY=0

  local whiteTop = display.newRect( quizzGame, q.cx, 0, q.fullw, 80 )
  whiteTop.anchorY=0

  local countLabel = display.newText({
    parent = quizzGame,
    text = "Вопрос 1/4",
    x=30,
    y=40,
    font="ubuntu_m.ttf",
    fontSize=24*2,
  })
  countLabel:setFillColor( 0 )
  countLabel.anchorX=0


  local butWidth = 335
  local butHeight = 220
  local butY = 840
  local backQuest = display.newRoundedRect(quizzGame, q.cx, 600,q.fullw-100, 320,30)
  backQuest.fill=q.CL"6120FF"

  local backL1 = display.newRoundedRect(quizzGame, q.fullw*.25+15, butY, butWidth,butHeight,30)
  backL1.anchorY=0
  backL1.fill=q.CL"1CD0FF"

  local backL2 = display.newRoundedRect(quizzGame, q.fullw*.25+15, butY+butHeight+35, butWidth,butHeight,30)
  backL2.anchorY=0
  backL2.fill=q.CL"1D91FF"

  local backR1 = display.newRoundedRect(quizzGame, q.fullw*.75-15, butY, butWidth,butHeight,30)
  backR1.anchorY=0
  backR1.fill=q.CL"00C2FF"

  local backR2 = display.newRoundedRect(quizzGame, q.fullw*.75-15, butY+butHeight+35, butWidth,butHeight,30)
  backR2.anchorY=0
  backR2.fill=q.CL"346BFF"
  
  backL1.i=1
  backL2.i=2
  backR1.i=3
  backR2.i=4

  local labelQuest = display.newText( {
    parent = quizzGame, 
    text ="Многократно повторяющаяся часть алгоритма", 
    x = q.cx, 
    y = backQuest.y, 
    font = "roboto_m.ttf",
    fontSize = 50,
    align = "center",
    width = backQuest.width-100
    })

  local labelL1 = display.newText( {
    parent = quizzGame, 
    text ="Объявления", 
    x = backL1.x, 
    y = backL1.y+backL1.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backL1.width
    })

  local labelL2 = display.newText( {
    parent = quizzGame, 
    text ="Циклы", 
    x = backL2.x, 
    y = backL2.y+backL2.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backL2.width
    })

  local labelR1 = display.newText( {
    parent = quizzGame, 
    text ="Условное выражение", 
    x = backR1.x, 
    y = backR1.y+backR1.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backR1.width
    })

  local labelR2 = display.newText( {
    parent = quizzGame, 
    text ="Переменная", 
    x = backR2.x, 
    y = backR2.y+backR2.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backR2.width
    })
  local backs = {
    backL1,
    backL2,
    backR1,
    backR2
  }

  local curretI = 0
  local questionsComplete = 0

  local rezult = {0,0,0}
  local waitAnswer
  local function checkCorrect(event)
  	local i = event.target.i
    -- if i==correctNow then
      -- event.target.fill=q.CL"93d9a6"
      questionsComplete = questionsComplete + 1
      local plus = quizzInfo.answers[curretI].balance[i]
      -- print(curretI,i,plus[1],plus[1])
      rezult[plus[1]] = rezult[plus[1]] + plus[2]
    -- else
    --   event.target.fill=q.CL"e9625a"
    --   backs[correctNow].fill=q.CL"93d9a6"
    -- end
    backL1:removeEventListener( "tap", checkCorrect )
    backL2:removeEventListener( "tap", checkCorrect )
    backR1:removeEventListener( "tap", checkCorrect )
    backR2:removeEventListener( "tap", checkCorrect )
    waitAnswer()
    -- timer.performWithDelay(1000, waitAnswer)
  end
  local function finish()
    display.remove(grayBack)
    countLabel.text = "Результаты"
    backQuest.y = 300
    labelQuest.y = 300
    backL1.alpha = 0
    backL2.alpha = 0
    backR1.alpha = 0
    backR2.alpha = 0

    labelL1.alpha = 0
    labelL2.alpha = 0
    labelR1.alpha = 0
    labelR2.alpha = 0

    local man = display.newImageRect( quizzGame, "img/man.png", 442, 1312 )
    man.x, man.y = 50, q.fullh-180
    man.anchorX, man.anchorY = 0, 1
    man.xScale, man.yScale = .58, .58
    man.alpha = .7

		local sum = 0
		local topMost = {}
		for i=1, #rezult do
			sum = sum + rezult[i]
			topMost[i] = {i,(rezult[i] + 1) - 1}
		end

		local a = function (a, b) return (a[2] > b[2]) end
		table.sort (topMost, a)
		-- print("the best",topMost[1][1],topMost[1][2])

		local finishLabel = ""
    local labels = {}
    for j=1, #rezult do
      local i = topMost[j][1]
      -- print(i,"i")
			labels[j] = display.newText( {
        parent = quizzGame,
        text = quizzInfo.praises.names[i].." "..q.round(rezult[i]/sum*100).."%\n",
        x=0,
        y=0,
        font="roboto_m.ttf",
        fontSize=20*2,
		  } )
      labels[j]:setFillColor( unpack( q.CL"503CFF" ) )
      labels[j].anchorX = 0
    end

    labels[1].x = 320
    labels[1].y = q.fullh-750

    labels[2].x = 340
    labels[2].y = q.fullh-750+110

    labels[3].x = 305
    labels[3].y = q.fullh-750+220

    labelQuest.text = quizzInfo.praises.long[topMost[1][1]]

    local exitBut = display.newRoundedRect(quizzGame, q.fullw-50, q.fullh-250, 400, 110,30)
    exitBut.anchorX=1
    exitBut.fill=q.CL"6120FF"

    local okLabel = display.newText( {
      parent = quizzGame,
      text = "OK",
      x=exitBut.x-exitBut.width*.5,
      y=exitBut.y,
      font="roboto_m.ttf",
      fontSize=20*2,
    } )
    okLabel:setFillColor( 1 )


    exitBut:addEventListener( "tap", toMain )

  
  end
  waitAnswer = function()
    curretI = curretI + 1
    local i = curretI
    
    -- backL1.fill = q.CL"1E3090"
    -- backL2.fill = q.CL"1E3090"
    -- backR1.fill = q.CL"1E3090"
    -- backR2.fill = q.CL"1E3090"
    if i>#quizzInfo.answers then
      finish() return
    end
    countLabel.text = "Вопрос "..i.."/"..#quizzInfo.questions

    correctNow = quizzInfo.answers[i][5]
    labelQuest.text = quizzInfo.questions[i]
    labelL1.text = quizzInfo.answers[i].text[1]
    labelL2.text = quizzInfo.answers[i].text[2]
    labelR1.text = quizzInfo.answers[i].text[3]
    labelR2.text = quizzInfo.answers[i].text[4]
    
    backL1:addEventListener( "tap", checkCorrect )
    backL2:addEventListener( "tap", checkCorrect )
    backR1:addEventListener( "tap", checkCorrect )
    backR2:addEventListener( "tap", checkCorrect )
  end
  waitAnswer()
  -- finish()
end

local kursesInfo = {

}
local function videoListener( event )
  print( "Event phase: " .. event.phase )
  if event.errorCode then
      native.showAlert( "Error!", event.errorMessage, { "OK" } )
  end
end
local allToms = {
  {
    title = "Курс верстки веб-страниц",
    discription = "Научитесь вносить правки в код веб-страницы и верстать текстовые блоки с нуля. Узнаете, как менять оформление и стиль отдельных элементов сайта",
    tomes = {
      {title="Теги для разметки и атрибуты",timecode="0:00 - 4:12",discription="Познакомитесь с тегами и их атрибутами. Узнаете, что такое вложенность тегов, поймёте, как сделать разметку читабельной и понятной. Разберётесь в порядке использования таких тегов, как абзац, цитата, ссылкаи картинка. Научитесь расставлять акценты в тексте"},
      {title="Списки и таблицы",timecode="4:13 - 6:28",discription="Изучите виды и порядок формирования списков и таблиц. Сформируете разметку для своего первого многоуровневого списка. Рассмотрите варианты оформления таблиц, научитесь делать заголовки и итоговые блоки, объединять ячейки с помощью атрибутов"},
      {title="Селекторы и свойства",timecode="6:29 - 10:45",discription="Познакомитесь с основами CSS. Узнаете, что такое селектор. Научитесь правильно описывать CSS-правила. Поймёте, как изменять размер шрифта, его начертание, цвет. Рассмотрите тему наследования свойств. Изучите вопрос, касающийся комбинирования селекторов"},
    }
  },
  {
    title = "Разработка UX для дизайнеров",
    discription = "Познакомитесь с ключевыми понятиями и принципами дизайна, лежащими в основе любого изображения и макета. Выполните практические задания по разработке сайтов и рекламной графики для закрепления материала",
    tomes = {
      {title="Кто такой UX-дизайнер?",timecode="0:00 - 5:28",discription="UX - Дизайнер востребованная сейчас профессия.. Один два три четыре пять шесть"},
      {title="Тестирование",timecode="5:29 - 10:28",discription="Тестирование - неотъемлемая часть разработки UX - дизайна"},
      {title="Название задачи",timecode="10:29 - 12:45",discription="Ключевая часть разработки дизайна - расстановка задач. Должны быть четкое определение как и что будет выглядить"},
    }
  },
  {
    title = "Unity для гейм-дизайнеров",
    discription = "Научитесь создавать и комбинировать игровые механики, чтобы не дать игроку заскучать. Изучите основы игровых движков, научитесь тестировать в них идеи, выдвигать гипотезы и проверять их",
    tomes = {
      {title="Разработка концепции игры",timecode="0:00 - 5:11",discription="Научитесь создавать сюжет и композицию игры, строить дизайн игрового пространства, карты уровней и карты маршрутов"},
      {title="Постановка задач",timecode="5:12 - 12:32",discription="Спроектируете игровые уровни и механики. Научитесь анализировать различные модели баланса игр. Составите техническую документацию"},
      {title="Продвижение игры",timecode="12:33 - 15:41",discription="Изучите основы монетизации игр. Поймёте, как работает авторское право. Узнаете, как вывести игровой продукт на рынок и сделать игру прибыльной"},
    }
  },
  {
    title = "Python для начинающих",
    discription = "Изучите основы одного из самых популярных языков программирования. Самостоятельно разработаете планировщик задач и Telegram-бота",
    tomes = {
      {title="Возможности Python",timecode="0:00 - 4:54",discription="Научитесь работать с данными и напишете свою первую программу. \n- Области использования Python \n- Общее представление о программировании\n- Инструменты для написания кода\n- Понятие переменной\n- Данные и работа с ними"},
      {title="Первая программа",timecode="4:55 - 8:39",discription="Начнёте разрабатывать приложение ToDo, которое позволит ставить задачи на определённую дату и управлять ими. Познакомитесь с базовыми конструкциями в Python: условными операторами и циклами.\n- Логические выражения\n- Условные конструкции\n- Добавление выбора действия в зависимости от введённой команды\n- Циклы for и while"},
      {title="Приложение ToDo",timecode="8:40 - 12:12",discription="Научитесь использовать сторонние библиотеки с готовым программным кодом и функциями, которые создали разработчики для решения многих типовых задач. Начнёте создавать свои собственные функции.\n- Роль и задачи функций\n- Использование сторонних библиотек\n- Написание функций для приложения ToDo"},
    }
  }
}
local function startKurs(event)
  if event.y>(q.fullh-125) or event.y<330 then return end
  q.event.group.off("kursesButtons")
  q.event.group.off("downBar")
  searchField.x = -1000
  searchField.y = -1000

  hideLayer("kurs")

  mainLabel.alpha = 0

  local title = allToms[event.target.i].title
  local discription = allToms[event.target.i].discription
  local tomes = allToms[event.target.i].tomes


  if kursGroup ~=nil then display.remove(kursGroup) end
  kursGroup = display.newGroup()
  kursScreen:insert( kursGroup )
  kursScreen:toFront( )

  local backGround = display.newRect(kursGroup, q.cx, q.cy, q.fullw, q.fullh)
  backGround.fill={.95}


  local backIcon = display.newImageRect( kursGroup, "img/back.png", 90, 90 )
  backIcon.anchorX = 0
  backIcon.x, backIcon.y = 30, 80

  local allKursLabel = display.newText( {
    parent = kursGroup,
    text = "Видео лекции",
    x=q.cx,
    y=backIcon.y,
    font="poppins_r.ttf",
    fontSize=16*2,
    } )
  allKursLabel:setFillColor( unpack( q.CL"201E22" ) )

  local videoPreview = display.newRoundedRect( kursGroup, q.cx, backIcon.y*2, q.fullw, 450, 40)
  videoPreview.fill = c.gray
  videoPreview.anchorY = 0
  videoPreview.fill = {
    type = "image",
    filename = "img/kurses/"..event.target.i.."_.jpg"
  }

  local alltimeback = display.newRoundedRect( kursGroup, q.fullw-30,videoPreview.y+videoPreview.height-30,100,45,20)
  alltimeback.anchorX=1
  alltimeback.anchorY=1
  alltimeback.fill = q.CL"EFF2F8"
  alltimeback.alpha = .8 
  local alltimeLabel = display.newText( {
    parent = kursGroup,
    text = "0:00",
    x=5,
    y=15,
    font="poppins_r.ttf",
    fontSize=14.6*2,
    } )
  alltimeLabel.x = alltimeback.x - alltimeback.width*.5 + 3
  alltimeLabel.y = alltimeback.y - alltimeback.height*.5 + 4
  alltimeLabel:setFillColor( unpack( q.CL"201E22" ) )


  local titleLabel = display.newText( {
    parent = kursGroup,
    text = title,
    x=50,
    y=videoPreview.y+videoPreview.height+100-28,
    font="poppins_r.ttf",
    fontSize=18*2,
    } )
  titleLabel.anchorX = 0
  titleLabel.anchorY = 0
  titleLabel:setFillColor( unpack( q.CL"201E22" ) )

  local discLabel = display.newText( {
    parent = kursGroup,
    text = discription,
    x=50,
    y=titleLabel.y+titleLabel.height+30,
    font="poppins_r.ttf",
    fontSize=14*2,
    width=q.fullw-50*2,
    } )
  discLabel.anchorX = 0
  discLabel.anchorY = 0
  discLabel:setFillColor( unpack( q.CL"626164" ) )


  local titleLabel = display.newText( {
    parent = kursGroup,
    text = "Главы видео",
    x=50,
    y=q.fullh-520,
    font="poppins_r.ttf",
    fontSize=18*2,
    } )
  titleLabel.anchorX = 0
  titleLabel.anchorY = 1
  titleLabel:setFillColor( unpack( q.CL"201E22" ) )


  local tomGroup
  local curretI = 0
  local tomLabel, discLabel
  local toBackLabel, toNextLabel
  local function nextTom()
    if curretI==3 then return end
    curretI = curretI + 1
    tomLabel.text = tomes[curretI].title
    discLabel.text = tomes[curretI].discription
    if curretI==3 then
      toBackLabel:setFillColor( unpack( q.CL"201E22" ) )
      toNextLabel:setFillColor( unpack( c.gray ) )
    else
      toBackLabel:setFillColor( unpack( q.CL"201E22" ) )
      toNextLabel:setFillColor( unpack( q.CL"201E22" ) )
    end
  end
  local function prevTom()
    if curretI==1 then return end
    curretI = curretI - 1
    tomLabel.text = tomes[curretI].title
    discLabel.text = tomes[curretI].discription
    if curretI==1 then
      toBackLabel:setFillColor( unpack( c.gray ) )
      toNextLabel:setFillColor( unpack( q.CL"201E22" ) )
    else
      toBackLabel:setFillColor( unpack( q.CL"201E22" ) )
      toNextLabel:setFillColor( unpack( q.CL"201E22" ) )
    end
  end
  local function genTomDiscription( event )
    if tomGroup~=nil then display.remove( tomGroup ) tomGroup=nil end
    tomGroup = display.newGroup()
    kursGroup:insert(tomGroup)
    local i = event.target.i
    curretI = i
    q.event.group.off("tomesButtons")

    tomGroup.y = q.fullh
    transition.to( tomGroup, {y=0, time=600, transition=easing.outSine} )

    local back = display.newRoundedRect( tomGroup, q.cx, q.fullh+100, q.fullw, 100+q.fullh-(videoPreview.y+videoPreview.height+60), 40 )
    back.anchorY=1
    back.fill = {.9}--c.gray2
    local y = back.y-back.height

    tomLabel = display.newText( {
      parent = tomGroup,
      text = tomes[i].title,
      x=50,
      y=y+40,
      font="poppins_m.ttf",
      fontSize=18*2,
    } )
    tomLabel.anchorX = 0
    tomLabel.anchorY = 0
    tomLabel:setFillColor( unpack( q.CL"201E22" ) )

    discLabel = display.newText( {
      parent = tomGroup,
      text = tomes[i].discription,
      x=50,
      y=y+40+70,
      font="poppins_r.ttf",
      fontSize=14.5*2,
      width=q.fullw-50*2,
    } )
    discLabel.anchorX = 0
    discLabel.anchorY = 0
    discLabel:setFillColor( unpack( q.CL"201E22" ) )

    local closeIcon = display.newImageRect( tomGroup, "img/close.png", 90, 90 )
    closeIcon.x, closeIcon.y = q.fullw-65, y+65

    toBackLabel = display.newText( {
      parent = tomGroup,
      text = "< Назад",
      x=50,
      y=q.fullh-30,
      font="poppins_r.ttf",
      fontSize=14.5*2,
    } )
    toBackLabel.anchorX = 0
    toBackLabel.anchorY = 1
    toBackLabel:setFillColor( unpack( q.CL"201E22" ) )
    if i==1 then 
      toBackLabel:setFillColor( unpack( c.gray ) )
    end
    toBackLabel:addEventListener( "tap", prevTom )

    toNextLabel = display.newText( {
      parent = tomGroup,
      text = "Вперёд >",
      x=q.fullw-50,
      y=q.fullh-30,
      font="poppins_r.ttf",
      fontSize=14.5*2,
    } )
    toNextLabel.anchorX = 1
    toNextLabel.anchorY = 1
    toNextLabel:setFillColor( unpack( q.CL"201E22" ) )
    if i==3 then 
      toNextLabel:setFillColor( unpack( c.gray ) )
    end
    toNextLabel:addEventListener( "tap", nextTom )


    closeIcon:addEventListener( "tap", function()
      transition.to( tomGroup, {y=q.fullh, time=400, transition=easing.inSine, onComplete=function()
        display.remove(tomGroup)
        q.event.group.on("tomesButtons")
      end} )
    end )
  end

  for i=1, #tomes do
    local img = display.newImageRect(kursGroup,"img/tom_template.png",140,140)
    img.anchorX = 0
    img.x, img.y = 50, titleLabel.y+165*i-60

    local moreInf = display.newImageRect( kursGroup, "img/tom_info.png", 64,64 )
    moreInf.anchorX=1
    moreInf.x, moreInf.y = q.fullw-50, img.y-5
    moreInf.i = i
    q.event.add("tomeInfo"..i, moreInf, genTomDiscription)
    q.event.group.add("tomesButtons","tomeInfo"..i)


    local tomLabel = display.newText( {
      parent = kursGroup,
      x = img.x+img.width+30,
      y = img.y+10,
      text = tomes[i].title,
      font = "poppins_r.ttf",
      fontSize = 14.5*2,
      } )
    tomLabel.anchorX=0
    tomLabel.anchorY=1
    tomLabel:setFillColor( unpack( q.CL"201E22" ) )

    local timecode = display.newText( {
      parent = kursGroup,
      x = img.x+img.width+30,
      y = img.y,
      text = tomes[i].timecode,
      font = "poppins_r.ttf",
      fontSize = 12.5*2,
      } )
    timecode.anchorX=0
    timecode.anchorY=0
    timecode:setFillColor( unpack( q.CL"626164" ) )
  end
  q.event.group.on("tomesButtons")


  -- genTomDiscription( {target={i=1}} )
  backIcon:addEventListener( "tap", toMain )
end

local function testsResponder(event)
  
  if ( event.isError)  then
    print( "Error!" )
  else
    local myNewData = event.response
    allQuizz = (json.decode(myNewData))
  
    for i=1, #allQuizz do
      allQuizz[i].answers = json.decode(allQuizz[i].answers) 
      allQuizz[i].questions = json.decode(allQuizz[i].questions)
      allQuizz[i].praises = json.decode(allQuizz[i].praises)
    end
    local allTestGroup = display.newGroup()
    testsGroup:insert(allTestGroup)

    local testHeight = 520
    for i=1, #allQuizz do
      local images = display.newRoundedRect(allTestGroup, q.cx, 335+(i-1)*(testHeight+30), q.fullw-30*2,testHeight,12)
      images.anchorY = 0
      images.fill = c.gray
      images.i = i
      q.event.add("playtest"..i, images, startQuizz)
      q.event.group.add("testsButtons","playtest"..i)

      local paint = {
        type = "image",
        -- filename = "img/news_template.png"
        filename = "img/tests/"..i..".jpg"
      }
      images.fill = paint

      local front = display.newRoundedRect(allTestGroup, q.cx, images.y+images.height, images.width,140,12)
      front.anchorY=1
      front.fill = c.gray2

      local frontUp = display.newRect(allTestGroup, q.cx, front.y-front.height, images.width,front.height*.5)
      frontUp.anchorY=0
      frontUp.fill = c.gray2

      local testsLabel = display.newText({
        parent = allTestGroup,
        text = allQuizz[i].title,
        x = 60,
        y = front.y - front.height*.5 - 25,
        font = "roboto_m.ttf",
        fontSize = 16*2,
        })
      testsLabel.anchorX = 0
      testsLabel:setFillColor( unpack( c.black ) )

      local dateLabel = display.newText({
        parent = allTestGroup,
        text = allQuizz[i].date,
        x = 60,
        y = testsLabel.y+45,
        font = "roboto_r.ttf",
        fontSize = 13*2,
        })
      dateLabel.anchorX = 0
      dateLabel:setFillColor( unpack( q.CL"818C99" ) )
    end
    q.event.group.on("testsButtons")
    local screenSize = q.fullh-330-125
    if #allQuizz>2 then
      allTestGroup.scrolltag = "test"
      scrollInfo.test.maxUp = (screenSize-(testHeight+30)*(#allQuizz))
      allTestGroup:addEventListener("touch", scroll)
    end
    topMain:toFront()

    -- startQuizz({target={i=1},y=q.cy})
  end
end

local function statisticResponder(event)
  if ( event.isError)  then
    print( "Error!" )
  else
    local myNewData = event.response
    -- print("Users ",myNewData)
    local statAll = json.decode( myNewData )
    local stat = statAll["1"]
    statGraf = statAll["2"]
    
    
    local sum = 0
    for i=1, #stat do
      sum = sum + stat[i]
    end
    local working = q.round(sum/#stat*100)
    local notWorking = 100 - working
    -- print("stat",#stat,sum)

    workingLabel = display.newText({
      parent = adminGroup,
      text = "- Занятых "..working.."%",
      x=290,
      y=180,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    workingLabel:setFillColor( unpack( c.black) )
    workingLabel.anchorX=0

    notWorkingLabel = display.newText({
      parent = adminGroup,
      text = "- Безработных "..notWorking.."%",
      x=130,
      y=370,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    notWorkingLabel:setFillColor( unpack( c.black) )
    notWorkingLabel.anchorX=0

    local statLabel = display.newText( {
      parent = adminGroup,
      text = "Трудоустроено за сутки",
      x = 35,
      y = 530,
      font = "ubuntu_m.ttf",
      fontSize = 20*2,
      } )

    statLabel:setFillColor( unpack( c.black) )
    statLabel.anchorX = 0
    
    statistic = working
  end
end

local function createTextFiled(x,y,paramText,ParamField)
  
  local label = display.newText( paramText.group, "-", x, y, paramText.font, paramText.fontSize)
  label:setFillColor(unpack(paramText.textColor))
  label.anchorX=0
  local oneSize = label.width
  label.text = paramText.text
  
  local back = display.newRect(paramText.group, label.width, y, label.width, label.height)
  back.anchorX=0
  back.fill = paramText.textColor

  local Field = native.newTextField(x+label.width+10, y, 400, 110)
  ParamField.group:insert( Field )
  Field.anchorX=0

  for k, v in pairs(ParamField.auto) do
    Field[k] = v
  end
  Field.height=label.height
  firldsTable[ParamField.key] = Field
  display.remove(label)
end

local incorrectChange
local function showPassWarning(text, time)
  timer.cancel( "passwarn" )
  transition.cancel( "passwarn" )
  
  time = time~=nil and time or 2000
  incorrectChange.text=text
  incorrectChange.alpha=1
  incorrectChange.fill.a=1
  timer.performWithDelay( time, 
  function()
    transition.to(incorrectChange.fill,{a=0,time=500, tag="passwarn"} )
  end, 1, "passwarn")
end
local function changeResponder(event)
  if ( event.isError) then
    print( "Error!", event.response)
  else
    local myNewData = event.response
    -- print("Server:"..myNewData)
    if myNewData=="Incorrect\n\n\n" then
      showPassWarning("Текущий пароль не верен")
    elseif myNewData=="PasswordChanged\n\n\n" then
      -- showPassWarning("Пароль изменён успешно!")
      closePCMenu()
    else
    -- elseif myNewData=="User not found\n\n\n" then
      showPassWarning("Упс.. Что-то пошло не так")
    end

  end
end




function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup() -- Группа фоновых элементов
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup() -- Группа основного экрана
	sceneGroup:insert(mainGroup)

  testsGroup = display.newGroup() -- Группа списка тестов
  mainGroup:insert(testsGroup)

  kursesGroup = display.newGroup() -- Группа списка курсов
  mainGroup:insert(kursesGroup)
  kursesGroup.alpha = 0

	eventGroup = display.newGroup() -- Группа списка новостей
	sceneGroup:insert(eventGroup)
	eventGroup.alpha = 0

	chatGroup = display.newGroup() -- Группа чата
	sceneGroup:insert(chatGroup)
	chatGroup.alpha = 0

	profileGroup = display.newGroup() -- Группа профиля
	sceneGroup:insert(profileGroup)
	profileGroup.alpha = 0

  local account = q.loadLogin()
  if account.lic=="admin" then
    adminGroup = display.newGroup()
    sceneGroup:insert(adminGroup)
    adminGroup.alpha = 0
  end


	uiGroup = display.newGroup() -- Группа общих элементов
	sceneGroup:insert(uiGroup)

	quizzScreen = display.newGroup() -- Группа для прохождения теста
	uiGroup:insert(quizzScreen)

  kursScreen = display.newGroup() -- Группа для просмотра курса
  uiGroup:insert(kursScreen)

  server = composer.getVariable( "ip" )

  local back = display.newRect( backGroup, q.cx, q.cy, q.fullw, q.fullh )

  mainLabel = display.newText( {
  	parent = uiGroup,
  	text = "Навигация",
  	x=30,
  	y=60,
  	font = "ubuntu_m.ttf",
  	fontSize = 24*2} )
  mainLabel.fill = c.black	
  mainLabel.anchorX = 0

  local downBack = display.newRect(uiGroup, q.cx, q.fullh, q.fullw, 125)
  downBack.anchorY = 1

  local shadow = display.newImageRect( uiGroup, "img/shadow.png", q.fullw, q.fullw*.0611 )
  shadow.x = q.cx
  shadow.y = q.fullh-downBack.height
  shadow.anchorY=1
  
  mainButton = display.newImageRect( uiGroup, "img/main.png", 58*2, 44*2 )
  mainButton.y = q.fullh - mainButton.height*.5-20
  mainButton.x = q.cx*.25+20
  mainButton:setFillColor( unpack( c.blue ) )
  q.event.add("toMain", mainButton, toMain)
  q.event.group.add("downBar","toMain")
  -- mainButton:addEventListener( "tap", toMain )

  eventButton = display.newImageRect( uiGroup, "img/events.png", 58*2, 44*2 )
  eventButton.y = q.fullh - eventButton.height*.5-20
  eventButton.x = q.cx*.75+10
  eventButton:setFillColor( unpack( c.grayButtons ) )
  q.event.add("toEvent", eventButton, toEvent)
  q.event.group.add("downBar","toEvent")
  -- eventButton:addEventListener( "tap", toEvent )

  chatButton = display.newImageRect( uiGroup, "img/chatsoon.png", 58*2, 44*2 )
  chatButton.y = q.fullh - chatButton.height*.5-20
  chatButton.x = q.cx*1.25-10
  chatButton:setFillColor( unpack( c.gray ) )
  q.event.add("toChat", chatButton, toChat)
  q.event.group.add("downBar","toChat")
  -- chatButton:addEventListener( "tap", toChat )

  local soonLabel = display.newText( {
  	parent = uiGroup,
  	text = "Soon!",
  	x=chatButton.x+5,
  	y=chatButton.y+25-5,
  	font = "ubuntu_m.ttf",
  	fontSize = 16*2} )
  soonLabel.fill = c.gray


  profileButton = display.newImageRect( uiGroup, "img/profile.png", 58*2, 44*2 )
  profileButton.y = q.fullh - profileButton.height*.5-20
  profileButton.x = q.cx*1.75-20
  profileButton:setFillColor( unpack( c.grayButtons ) )
  q.event.add("toAccount", profileButton, toAccount)
  q.event.group.add("downBar","toAccount")
  -- profileButton:addEventListener( "tap", toAccount )

  q.event.group.on("downBar")
  
  

  -- ========================
  -- ------------------------
  -- ========================


  topMain = display.newGroup()
  mainGroup:insert(topMain)

  local backTop = display.newRect(topMain, q.cx, 0, q.fullw, 330)
  backTop.anchorY=0
  backTop.fill = c.white

  local buttonTests = display.newRect(topMain, 0, 200, q.cx, 100)
  -- buttonTests.fill = c.gray
  buttonTests.alpha = .01
  buttonTests.anchorX=0
  buttonTests.anchorY=1
  buttonTests:addEventListener( "tap", toTests )

  local buttonKurs = display.newRect(topMain, q.cx, 200, q.cx, 100)
  -- buttonKurs.fill = c.gray
  buttonKurs.alpha = .01
  buttonKurs.anchorX=0
  buttonKurs.anchorY=1
  buttonKurs:addEventListener( "tap", toKurs )

  usLabel = display.newText( {
  	parent = topMain,
  	text = "Онлайн-тесты",
  	x=q.cx*.5,
  	y=140+5,
  	font = "ubuntu_m.ttf",
  	fontSize = 16*2} )
  usLabel.fill = c.black

  vacLabel = display.newText( {
  	parent = topMain,
  	text = "Курсы",
  	x=q.cx*1.5,
  	y=140+5,
  	font = "ubuntu_m.ttf",
  	fontSize = 16*2} )
  vacLabel.fill = c.gray

  selectedRect = display.newRect(topMain, 0,190+10, q.cx, 11)
  selectedRect.anchorX = 0
  selectedRect.fill = c.blue


  local back = display.newRoundedRect(topMain, 30, 270, q.fullw-30*2, 92, 6)
	back.fill = c.gray2
	back.anchorX = 0

	local searchIcon = display.newImageRect( topMain, "img/search.png", 40, 40 )
	searchIcon.y = back.y
	searchIcon.x = 75
	
	searchField = native.newTextField(back.x+80, back.y, back.width-80, 90)
	topMain:insert( searchField )
	searchField.anchorX=0
	searchField.pos = {x=searchField.x, y=searchField.y}
	searchField.isEditable=true
	searchField.hasBackground = false
	searchField.placeholder = "Поиск"
	searchField.font = native.newFont( "ubuntu_r.ttf",16*2)
  searchField:resizeHeightToFitFont()
	-- searchField.height = 48
	searchField:setTextColor( 0, 0, 0 )

	
  if isDevice then
    local data = q.getConnection("tests")
    testsResponder({response=data})
  else
    network.request( "http://"..server.."/dashboard/testsDownload.php", "GET",testsResponder )
  end
  -- ------------------------
  local function kursesAdd(event)
    if ( event.isError)  then
      print( "Error!" )
    else
      local myNewData = event.response
      local dataKurs = (json.decode(myNewData))
      
      local space = 60
      local testHeight = (q.fullw-3*space)*.5

      for i=1, #dataKurs do
        local images = display.newRoundedRect(kursesGroup, q.cx*.53, 370+math.floor((i-1)/2)*(testHeight+200), testHeight, testHeight,30)
        images.anchorY = 0
        images.fill = c.gray
        images.i = i
        if i%2==0 then
          images.x = q.cx*1.47
        end

        local paint = {
          type = "image",
          -- filename = "img/kurs_template.png"
          filename = "img/kurses/"..i..".jpg"
        }
        images.fill = paint
        q.event.add("playkurs"..i, images, startKurs)
        q.event.group.add("kursesButtons","playkurs"..i)

        local discpriptionLabel = display.newText({
          parent = kursesGroup,
          text = dataKurs[i].title,
          -- text = "AAAAAAA",
          x = images.x-images.width*.5+10,
          y = images.y+images.width+15,
          width = testHeight-20,
          font = "poppins_r.ttf",
          fontSize = 14*2,
          })
        discpriptionLabel.anchorX = 0
        discpriptionLabel.anchorY = 0
        discpriptionLabel:setFillColor( unpack( c.black ) )

        local star = display.newImageRect( kursesGroup, "img/star.png", 35, 35 )
        star.x, star.y = discpriptionLabel.x, discpriptionLabel.y + discpriptionLabel.height-25 + 20
        star.anchorX = 0
        star.anchorY = 0

        dataKurs[i].rate = "4.9"
        local rateLabel = display.newText({
          parent = kursesGroup,
          text = dataKurs[i].rate,
          x = star.x+star.width,
          y = star.y+star.height*.5+4,
          width = testHeight-20,
          font = "poppins_r.ttf",
          fontSize = 13*2,
          })
        rateLabel.anchorX = 0
        -- rateLabel.anchorY = 0
        rateLabel:setFillColor( unpack( q.CL"626164" ) )

      end
      q.event.group.on("kursesButtons")
      -- startKurs({y=q.cy})

    end
  end
  if isDevice then
    local data = q.getConnection("kurses")
    kursesAdd({response=data})
  else
    network.request( "http://"..server.."/dashboard/kursesDownload.php", "GET",kursesAdd )
  end
	

	-- ========================
  -- ------------------------
  -- ========================
  local backTopNews = display.newRect(eventGroup, q.cx, 0, q.fullw, 110)
  backTopNews.anchorY=0
  backTopNews.fill = c.white

  local newsBodys = {}
  local allHeight = 130
  local function drawNews(group, y, title, date)
    local thisNews = display.newGroup()
    group:insert( thisNews )
    thisNews.y = y
    table.insert( newsBodys, 1, thisNews )

    local newsLabel = display.newText({
      parent = thisNews,
      text = title,
      x = 60,
      y = 30,
      width = q.fullw-100,
      font = "ubuntu_m.ttf",
      fontSize = 16*2,
      })
    newsLabel.anchorX = 0
    newsLabel.anchorY = 0
    newsLabel:setFillColor( unpack( c.black ) )

    local back = display.newRoundedRect(thisNews, q.cx, 0, q.fullw-60, 120+newsLabel.height, 12)
    back.anchorY=0
    back.fill = c.gray2
    back:toBack()
    allHeight = allHeight + back.height + 30

    local dateLabel = display.newText({
      parent = thisNews,
      text = date,
      x = 60,
      y = back.height-50,
      font = "roboto_r.ttf",
      fontSize = 13*2,
      })
    dateLabel.anchorX = 0
    dateLabel:setFillColor( unpack( q.CL"818C99" ) )
  end
  local viewSpace = q.fullh - backTopNews.height - downBack.height
  local function checkIfNeedScroll(group)
    -- print("hah",viewSpace,allHeight,viewSpace-allHeight)
    if allHeight>viewSpace then
      group.scrolltag = "news"
      scrollInfo.news.maxUp = viewSpace-allHeight
      group:addEventListener("touch", scroll)
    end
  end
  local function newsAdd(event)
    if ( event.isError)  then
      print( "Error:", event.response)
    else
      local myNewData = event.response
      -- print("news",myNewData)
      local inverseRealEvent = (json.decode(myNewData))
      local realEvent = {}
      local j = 1
      for i=#inverseRealEvent, 1, -1 do
        realEvent[j] = inverseRealEvent[i] -- Переворачиваем список чтобы сначало были свежие новости
        j = j + 1
      end
      j = nil

      local testHeight = 520
      local events = display.newGroup()
      eventGroup:insert(events)
      events:toBack( )
      for i=1, #realEvent do
        drawNews(events, allHeight, realEvent[i].title, realEvent[i].datePost)
      end

      if account.lic=="admin" then
        local publicated = 0

        local down = display.newRect(eventGroup, q.cx, q.fullh, q.fullw, 260)
        down.anchorY=1

        local createNewsButton, labelNews = createButton(eventGroup, "СОЗДАТЬ НОВОСТЬ",q.fullh-150,"id")
        createNewsButton:addEventListener( "tap", function()
          createNewsButton.alpha = 0
          labelNews.alpha = 0
          mainLabel.text = "Создание новости"
          local createNewsGroup = display.newGroup()
          eventGroup:insert(createNewsGroup)

          local back = display.newRect(createNewsGroup, q.cx, q.cy, q.fullw, q.fullh)

          local backTitle = display.newRoundedRect(createNewsGroup, 40, 180, q.fullw-40*2, 90, 12)
          backTitle.anchorX=0
          backTitle.fill = c.gray2

          local titleField = native.newTextField(60, 180, back.width-120, 90)
          createNewsGroup:insert( titleField )
          titleField.anchorX=0
          titleField.pos = {x=titleField.x, y=titleField.y}
          titleField.isEditable = true
          titleField.hasBackground = false
          titleField.placeholder = "Название"
          titleField.font = native.newFont( "ubuntu_r.ttf",16*2)
          titleField:resizeHeightToFitFont()
          titleField:setTextColor( .5, .5, .5 )

          local backLong = display.newRoundedRect(createNewsGroup, 40, 300-45, q.fullw-40*2, 630, 12)
          backLong.anchorX=0
          backLong.anchorY=0
          backLong.fill = c.gray2

          local longField = native.newTextBox(60, 300-45+20, back.width-120, 590)
          createNewsGroup:insert( longField )
          longField.anchorX = 0
          longField.anchorY = 0
          longField.pos = {x=longField.x, y=longField.y}
          longField.isEditable = true
          longField.hasBackground = false
          longField.placeholder = "Тело новости"
          longField.font = native.newFont( "ubuntu_r.ttf",16*2)
          longField:setTextColor( .5, .5, .5 )

          local submitNews, label = createButton(createNewsGroup, "ОПУБЛИКОВАТЬ",q.fullh-150-120,"id")
          submitNews:addEventListener( "tap", function() 
            publicated = publicated + 1
            local time = os.date("!*t",os.time())
            time = time.day.." "..os.date("%B",os.time()).." "..time.year
            

            inverseRealEvent[#inverseRealEvent+1] = {title=titleField.text, datePost=time, text=""}
            table.insert(realEvent, 1, {title=titleField.text, datePost=time, text=""} )
            if isDevice then
              q.postConnection("news",inverseRealEvent)
            else
              network.request( "http://"..server.."/dashboard/newsUpload.php?title="..titleField.text.."&date="..time, "GET" )
            end

            local before = allHeight+0
            drawNews(events, 130, titleField.text, time)
            local blockHeight = allHeight - before - 30
            for i=2, #newsBodys do
              newsBodys[i].y = newsBodys[i].y + blockHeight + 30
            end
            allHeight = allHeight
            checkIfNeedScroll(events)
            
            mainLabel.text = "События"
            display.remove(createNewsGroup)
            createNewsButton.alpha = 1
            labelNews.alpha = 1
          end)
          closeCN = function()
            display.remove(createNewsGroup)
            createNewsButton.alpha = 1
            labelNews.alpha = 1
          end
          local cancelNews, label = createButton(createNewsGroup, "ОТМЕНА",q.fullh-150,"id")
          cancelNews:addEventListener( "tap", function()
            mainLabel.text = "События"
            closeCN()
          end )

        end)
      end
      checkIfNeedScroll(events)
      -- q.event.group.on("testsButtons")
      if #realEvent>2 then
        -- maxUp = -(testHeight+30)*(#realEvent-2)+160
        -- events:addEventListener("touch", scroll)
      end
    end
  end
  if isDevice then
    local data = q.getConnection("news")
    newsAdd({response=data})
  else
    network.request( "http://"..server.."/dashboard/newsDownload.php", "GET",newsAdd )
  end
  
  

  -- ========================
  -- ------------------------
  -- ========================



  -- local notificationButton = display.newImageRect( chatGroup, "img/notifications.png", 60, 60 )
  -- notificationButton.x = q.fullw-60
  -- notificationButton.y = mainLabel.y+5

  -- local newchatButton = display.newImageRect( chatGroup, "img/newchat.png", 60, 60 )
  -- newchatButton.x = q.fullw-140
  -- newchatButton.y = mainLabel.y+5

  -- local databaseChats = {
  -- 	{person1=66121,person2=66122,},
  -- 	{person1=66123,person2=66124,},
  -- 	{person1=66125,person2=66126,},
  -- 	{person1=66127,person2=66121,},
  -- }
  -- local myBase = {}
  -- for i=1, #databaseChats do
  -- 	if tostring(databaseChats[i].person1)==account.id or tostring(databaseChats[i].person2)==account.id then
  -- 		-- local not
  -- 		myBase[#myBase+1] = {names={}}
  -- 	end
  -- end

  -- local chats = {}

  -- for i=1, #databaseChats do
  -- 	for k, v in pairs(databaseChats[i]) do
  -- 		if k==account.id then
  -- 			print("chat is "..i)
  -- 		end
  -- 	end
  -- end

  -- ========================
  -- ------------------------
  -- ========================

  local backAvatar = display.newCircle( profileGroup, 160, 270-30, 90 )
  backAvatar.fill = c.gray2

  local penIcon = display.newImageRect( profileGroup, "img/pen.png", 50, 50 )
  penIcon.x = backAvatar.x
  penIcon.y = backAvatar.y

  local nameLabel = textWithLetterSpacing({
  	parent = profileGroup,
  	x=290,
  	y=backAvatar.y-20,
  	text = account.name:sub(1,#account.name-(account.name:reverse()):find(" ")),
  	font = "ubuntu_m.ttf",
  	fontSize = 16*2,
  	color = c.black,
  	}, 15)

  local sityLabel = textWithLetterSpacing({
  	parent = profileGroup,
  	x=290,
  	y=backAvatar.y+20,
  	text = account.sity,
  	font = "ubuntu_r.ttf",
  	fontSize = 16*2,
  	color = c.gray,
  	}, 15)

  local line = display.newRect( profileGroup, q.cx, 380, q.fullw-100, 6 )
  line.fill = c.gray2

  local infoLabel = display.newText( {
  	parent = profileGroup,
  	text = "Данные",
  	x=70,
  	y=line.y+70,
  	font = "ubuntu_m.ttf",
  	fontSize = 16*2} )
  infoLabel.fill = c.black
  infoLabel.anchorX = 0

  local infoShow = {
  	{account.signupdate,"Дата регистрации"},
    {account.id,"ID"},
  }
  if account.lic=="user" then
    -- infoShow[3] = {account.working=="1" and "Да" or "Нет","Работаю ли"}
  end

  for i=1, #infoShow do
  	local infoLabel = display.newText( {
  	parent = profileGroup,
  	text = infoShow[i][2],
  	x=70,
  	y=510+50*(i-1),
  	font = "ubuntu_m.ttf",
  	fontSize = 16*2} )
  	infoLabel.anchorX = 0
  	infoLabel.fill = c.gray

  	local infoLabel = display.newText( {
  	parent = profileGroup,
  	text = infoShow[i][1],
  	x=q.fullw-70,
  	y=510+50*(i-1),
  	font = "ubuntu_r.ttf",
  	fontSize = 16*2} )
  	infoLabel.anchorX = 1
  	infoLabel.fill = c.black
  end

  local line = display.newRect( profileGroup, q.cx,510+50*(#infoShow-1)+70, q.fullw-100, 6 )
  line.fill = c.gray2

  -- local createButton(profileGroup, "ИЗМЕНИТЬ АВАТАРКУ",740,"id")
  local change = createButton(profileGroup, "СМЕНИТЬ ПАРОЛЬ",925-125,"id")
  local logOut = createButton(profileGroup, "ВЫЙТИ",925,"id")
  
  local changeWorkButton, workStatusLabel
  if account.lic=="user" then
    changeWorkButton, workStatusLabel = createButton(profileGroup, account.working=="1" and "ПОТЕРЯЛ РАБОТУ" or "УСТРОИЛСЯ НА РАБОТУ",925+125,"id")
    changeWorkButton:addEventListener( "tap", function()
      changeWorkButton.fill = q.CL"4d327a"
      local r,g,b = unpack( c.blue )
      timer.performWithDelay( 400, 
      function()
        transition.to(changeWorkButton.fill,{r=r,g=g,b=b,time=300} )
      end)
      display.remove(workStatusLabel)
      local newText
      if account.working=="1" then
        account.working="0"
        newText = "УСТРОИЛСЯ НА РАБОТУ"
      else
        account.working="1"
        newText = "ПОТЕРЯЛ РАБОТУ"
      end
      workStatusLabel = textWithLetterSpacing( {
        parent = profileGroup, 
        text = newText, 
        x = changeWorkButton.x+changeWorkButton.width*.5, 
        y = changeWorkButton.y-changeWorkButton.height*.5, 
        font = "ubuntu_b.ttf", 
        fontSize = 14*2
        }, 10, .5)
      q.saveLogin(account)
      if isDevice then
        -- {"1":["0","1","0"],"2":["{\"2022-02-02\":1,}","{\"2022-02-02\":1,}","{\"2022-02-02\":1,}"]}

        local statData = json.decode( q.getConnection("static") )
        statData["1"][tonumber(account.id)] = account.working
        if account.working=="1" then
          local time = getDay(0)
          if statData["2"][time]~=nil then
            statData["2"][time] = statData["2"][time] + 1
          else
            statData["2"][time] = 1
          end
        end
        q.postConnection("static", statData)
      else
        network.request( "http://"..server.."/dashboard/changeWork.php?email="..account.email, "GET" )
      end

    end )
  end

  logOut:addEventListener( "tap", function()
    q.saveLogin({})
    composer.gotoScene( "signin"  )
    composer.removeScene( "menu"  )
  end )

  local adminBut
  change:addEventListener( "tap", function() 
    change.alpha=0
    logOut.alpha=0
    if changeWorkButton then
      changeWorkButton.alpha=0
    end
    if adminBut then
      adminBut.alpha=0
    end
    local changeLayer = display.newGroup()
    profileGroup:insert(changeLayer)

    local back = display.newRoundedRect(changeLayer, 50, 865-125*2+30, q.fullw-50*2, 80, 6)
    back.fill = c.gray2
    back.anchorX = 0

    local oldPass = native.newTextField(back.x+30, back.y, back.width-30*2, 90)
    changeLayer:insert( oldPass )
    oldPass.anchorX=0
    oldPass.pos = {x=oldPass.x, y=oldPass.y}
    oldPass.isEditable=true
    oldPass.hasBackground = false
    oldPass.placeholder = "Текущий пароль"
    oldPass.font = native.newFont( "ubuntu_r.ttf",16*2)
    oldPass:resizeHeightToFitFont()
    oldPass:setTextColor( 0, 0, 0 )


    local back = display.newRoundedRect(changeLayer, 50, back.y+100, q.fullw-50*2, 80, 6)
    back.fill = c.gray2
    back.anchorX = 0

    local newPass = native.newTextField(back.x+30, back.y, back.width-30*2, 90)
    changeLayer:insert( newPass )
    newPass.anchorX=0
    newPass.pos = {x=oldPass.x, y=oldPass.y}
    newPass.isEditable=true
    newPass.hasBackground = false
    newPass.placeholder = "Новый пароль"
    newPass.font = native.newFont( "ubuntu_r.ttf",16*2)
    newPass:resizeHeightToFitFont()
    newPass:setTextColor( 0, 0, 0 )

    
    

    local okButton = createButton(changeLayer, "ОК",965-50,"okPass")
    okButton:addEventListener( "tap", function()
      okButton.fill = q.CL"4d327a"
      local r,g,b = unpack( c.blue )
      timer.performWithDelay( 400, 
      function()
        transition.to(okButton.fill,{r=r,g=g,b=b,time=300} )
      end)

      local textOldPass, textNewPass = oldPass.text, newPass.text
      if #textOldPass==0 then
        showPassWarning("Введите текущий пароль")
      elseif #textNewPass==0 then
        showPassWarning("Введите новый пароль")
      elseif #textOldPass<8 or #textNewPass<8 then
        showPassWarning("Пароли от 8 символов")
      elseif textOldPass==textNewPass then
        showPassWarning("Пароли не могут совпадать")
      else
        network.request( "http://"..server.."/dashboard/changePassword.php?oldpassword="..oldPass.text.."&newpassword="..newPass.text.."&email="..account.email, "GET", changeResponder )
      end

    end )

    closePCMenu = function()
      display.remove(changeLayer)
      change.alpha=1
      logOut.alpha=1
      if changeWorkButton then
        changeWorkButton.alpha=1
      end
      if adminBut then
        adminBut.alpha=1
      end
    end
    local cancelButton = createButton(changeLayer, "ОТМЕНА",965+100-30,"cancelPass")
    cancelButton:addEventListener( "tap", closePCMenu )

    incorrectChange = display.newText({
      parent = changeLayer,
      text = "Ошибка!",
      x=50,
      y=cancelButton.y+50,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    incorrectChange:setFillColor( unpack( q.CL"e07682") )
    incorrectChange.anchorX=0
    incorrectChange.alpha=0
  end)



  if account.lic=="admin" then
    adminBut = createButton(profileGroup, "АДМИН-МЕНЮ",925+125,"id")
    adminBut:addEventListener( "tap", toAdmin )
    -- -- --
    if isDevice then
        local data = q.getConnection("static")
        statisticResponder({response=data --[[]]})
      else
      network.request( "http://"..server.."/dashboard/allWorking.php", "GET", statisticResponder )
    end

  end

  -- ========================
  -- ------------------------
  -- ========================
  
  

end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		-- toAccount()
      toKurs()
      -- print("openninnnnnnnng")
    -- toEvent()
		-- toChat()

    -- timer.performWithDelay( 100, 
    -- toAdmin )
	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
    -- q.event.group.off()
    -- composer.removeScene( "menu" )
    -- print("scene hide")

	end
end


function scene:destroy( event )

	local sceneGroup = self.view
  q.event.clearAll()
  print("scene destroy")

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene

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

local backGroup, mainGroup, testsGroup, kursGroup, eventGroup, chatGroup, profileGroup, adminGroup, uiGroup, quizScreen

local q = require"base"

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
local maxUp = 0
local maxDown = 0
local cancelTouch = false
local server
local function scroll(event)
  local phase = event.phase
  local scrollingGroup = event.target
  display.currentStage:setFocus( scrollingGroup )

  if ( "began" == phase ) then
    if event.y>(q.fullh-125) or event.y<330 then cancelTouch = true display.currentStage:setFocus( nil ) return end
    cancelTouch = false
    scrollingGroup.mouseY = event.y
    scrollingGroup.oldposY = scrollingGroup.y
  elseif ( "moved" == phase ) then
    if cancelTouch then return end
    if scrollingGroup.mouseY and scrollingGroup.oldposY then
        
      -- print(event.y-scrollingGroup.mouseY)
      if (event.y-scrollingGroup.mouseY>maxDown) and scrollingGroup.y>maxDown then 
        scrollingGroup.y = maxDown
        display.currentStage:setFocus( nil )
        cancelTouch = true
        return 
      elseif (event.y-scrollingGroup.mouseY<maxDown) and scrollingGroup.y<maxUp then 
        cancelTouch = true
        scrollingGroup.y = maxUp
        display.currentStage:setFocus( nil )
        return
      end

      scrollingGroup.y = scrollingGroup.oldposY+(event.y-scrollingGroup.mouseY)
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
local quizGame, quizCreate
local function hideLayer(toScene)
  if quizGame~=nil then
    display.remove(quizGame)
    q.event.group.on("testsButtons")
    searchField.x = searchField.pos.x
    searchField.y = searchField.pos.y
	end
  if nowScene==toScene then return end
	timer.performWithDelay( 1, function()
		if nowScene == "menu" then
	  	mainButton:setFillColor( unpack( c.grayButtons ) )
			searchField.x = -1000
			searchField.y = -1000
			timer.performWithDelay( 1, function()
				mainGroup.alpha = 0
			end )
		elseif nowScene == "profile" then
			profileGroup.alpha = 0
	  	profileButton:setFillColor( unpack( c.grayButtons ) )
		elseif nowScene == "chat" then
			chatGroup.alpha = 0
	  	chatButton:setFillColor( unpack( c.grayButtons ) )
		elseif nowScene == "event" then
			eventGroup.alpha = 0
	  	eventButton:setFillColor( unpack( c.grayButtons ) )
    elseif nowScene == "admin" then
      adminGroup.alpha = 0
      display.remove(graf)
		end
	end )
end 

local function toMain()
	hideLayer("menu")
	timer.performWithDelay( 2, function()
		nowScene = "menu"
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
		nowScene = "event"
		mainLabel.text = "События"
	  eventButton:setFillColor( unpack( c.blue ) )
		eventGroup.alpha = 1
	end )
end

local function toChat()
	hideLayer("chat")
	timer.performWithDelay( 2, function()
		nowScene = "chat"
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

    if realPercent<50 then
      citc.anchorX = 0
    elseif realPercent<75 then
      citc.anchorX = ((citc.width-dlin)/dlin)*.5
    elseif realPercent<100 then
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
  display.remove(quizScreen) quizScreen=nil
  if event.target.name=="Tasks" then
    timer.performWithDelay( 1, function()
      q.event.group.on("levelsButtons")
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
  -- display.remove(quizScreen) quizScreen=nil
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
      local j = #statGraf[dates[i]]
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

local statistic
local function toAdmin()
  hideLayer("admin")
  timer.performWithDelay( 2, function()
    nowScene = "admin"
    mainLabel.text = "Администрирование"
    -- profileButton:setFillColor( unpack( c.blue ) )
    -- if statistic>50 then statistic=49 end
    local left = statistic>50
    local thisStat = statistic
    if left then thisStat = 100 - thisStat end
    local i = 0
    timer.performWithDelay( 150/5, function()
      i = i + 1
      display.remove(citc)
      genCircle(i, 180, 240, left) 
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
  kursGroup.alpha = 1
  transition.to(selectedRect,{x=q.cx,time=500, transition=easing.inOutBack })
  usLabel.fill = c.gray
  vacLabel.fill = {0,0,0}
end
local function toTests()
  if navMenuNow == "tests" then return end
  navMenuNow = "tests"
  testsGroup.alpha = 1
  kursGroup.alpha = 0
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



local function closeQuiz(event)
  print("quizScreen")
  display.remove(quizScreen) quizScreen=nil
  if event.target.name=="Tasks" then
    -- timer.performWithDelay( 1, function()
    --   q.event.group.on("levelsButtons")
    -- end)
  end
end
local json = require( "json" )

local function jsonForUrl(val)
  return q.jsonForUrl( json.encode( val ) )
end

local function networkListener( event )
 
    if ( event.isError)  then
    else
      local myNewData = event.response

    end
     
    return
end
local function sendQuiz(name, quiz)
  if name==nil then name = quiz.title end
  local quests = jsonForUrl( quiz.questions )
  local answers = jsonForUrl( quiz.answers )
  local praises = jsonForUrl( quiz.praises )
  -- print(server)
  -- print("http://"..server.."/dashboard/testUpload.php?title="..name.."&questions="..quests.."&answers="..answers.."&praises"..praises)
  network.request( "http://"..server.."/dashboard/testUpload.php?title="..name.."&questions="..quests.."&answers="..answers.."&praises="..praises, "GET", networkListener )

end


local allQuiz = {}
local topMain


local quizInfo = {}
local function startQuiz(event)
  if event.y>(q.fullh-125) or event.y<330 then return end
  q.event.group.off("testsButtons")
  searchField.x = -1000
	searchField.y = -1000

  quizInfo = allQuiz[event.target.i]
  -- sendQuiz(nil,quizInfo)
  mainLabel.text = "Тест"

  quizGame = display.newGroup()
  quizScreen:insert( quizGame )

  local backGround = display.newRect(quizGame, q.cx, q.cy, q.fullw, q.fullh)
  backGround.fill={.95}

  local backQuest = display.newRoundedRect(quizGame, q.cx, 600,q.fullw-100,500,20)
  backQuest.fill=q.CL"1E3090"

  local backL1 = display.newRoundedRect(quizGame, q.fullw*.25+10, 900,320,200,20)
  backL1.anchorY=0
  backL1.fill=q.CL"1E3090"

  local backL2 = display.newRoundedRect(quizGame, q.fullw*.25+10, 900+250,320,200,20)
  backL2.anchorY=0
  backL2.fill=q.CL"1E3090"

  local backR1 = display.newRoundedRect(quizGame, q.fullw*.75-15, 900,330,200,20)
  backR1.anchorY=0
  backR1.fill=q.CL"1E3090"

  local backR2 = display.newRoundedRect(quizGame, q.fullw*.75-15, 900+250,330,200,20)
  backR2.anchorY=0
  backR2.fill=q.CL"1E3090"
  
  backL1.i=1
  backL2.i=2
  backR1.i=3
  backR2.i=4

  local labelQuest = display.newText( {
    parent = quizGame, 
    text ="Многократно повторяющаяся часть алгоритма", 
    x = q.cx, 
    y = backQuest.y, 
    font = "roboto_r.ttf",
    fontSize = 50,
    align = "center",
    width = backQuest.width
    })

  local labelL1 = display.newText( {
    parent = quizGame, 
    text ="Объявления", 
    x = backL1.x, 
    y = backL1.y+backL1.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backL1.width
    })

  local labelL2 = display.newText( {
    parent = quizGame, 
    text ="Циклы", 
    x = backL2.x, 
    y = backL2.y+backL2.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backL2.width
    })

  local labelR1 = display.newText( {
    parent = quizGame, 
    text ="Условное выражение", 
    x = backR1.x, 
    y = backR1.y+backR1.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backR1.width
    })

  local labelR2 = display.newText( {
    parent = quizGame, 
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
      event.target.fill=q.CL"93d9a6"
      questionsComplete = questionsComplete + 1
      local plus = quizInfo.answers[curretI].balance[i]
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
    backQuest.y = 400
    labelQuest.y = 400
    backL1.alpha = 0
    backL2.alpha = 0
    backR1.alpha = 0
    backR2.alpha = 0

    labelL1.alpha = 0
    labelL2.alpha = 0
    labelR1.alpha = 0
    labelR2.alpha = 0

		local sum = 0
		local topMost = {}
		for i=1, #rezult do
			sum = sum + rezult[i]
			topMost[i] = {i,(rezult[i] + 1) - 1}
		end

		local a = function (a, b) return (a[2] > b[2]) end
		table.sort (topMost, a)
		print(topMost[1][1],topMost[1][2])

		local finishLabel = ""
		for i=1, #rezult do
			finishLabel = finishLabel .. quizInfo.praises.names[i].." "..q.round(rezult[i]/sum*100).."%\n"
		end

    labelQuest.text = finishLabel
    backQuest:addEventListener( "tap", function()
      display.remove( quizGame )
      timer.performWithDelay( 1, function()
        q.event.group.on("testsButtons")
      end )
    end )

    local praiseLabel = display.newText( {
			parent = quizGame,
			text = quizInfo.praises.names[topMost[1][1]].."\n"..quizInfo.praises.long[topMost[1][1]],
			x=q.cx,
			y=q.cy-180,
			font = "ubuntu_m.ttf",
      fontSize = 16*2,
			width = q.fullw-30,
      } )
		praiseLabel.fill = c.black
    praiseLabel.anchorY=0

    -- local today = os.date("*t",os.time())
    -- local month, day = today.month, today.day
    -- if tonumber(month)<10 then month = "0"..month end
    -- if tonumber(day)<10 then month = "0"..day end
    -- local todayString = today.year.."-"..month.."-"..day
    -- local account = q.loadLogin()
    -- -- network.request( "http://"..server.."/dashboard/xpCount.php?xpCount=".."15".."&email="..account[1].."&date="..todayString, "GET" )
    -- stats = q.loadStats()
    -- stats.xp = stats.xp + 15
    -- q.saveStats(stats)
    -- frontEXP.xScale = (stats.xp+1)/maxXp
    -- percLabel.text = stats.xp .. "%"
    -- if ((stats.xp)/maxXp)*100<20 then
    --   percLabel.x = frontEXP.x+frontEXP.width*frontEXP.xScale-15
    --   percLabel.anchorX=0 
    --   percLabel:setFillColor( unpack(q.CL"acf0f6") )
    -- else
    --   percLabel.x = frontEXP.x+frontEXP.width*frontEXP.xScale-15
    --   percLabel.anchorX=1
    --   percLabel:setFillColor( unpack(q.CL"1E3090") )
    -- end
  end
  waitAnswer = function()
    curretI = curretI + 1
    local i = curretI
    
    backL1.fill = q.CL"1E3090"
    backL2.fill = q.CL"1E3090"
    backR1.fill = q.CL"1E3090"
    backR2.fill = q.CL"1E3090"
    if i>#quizInfo.answers then
      finish() return
    end

    correctNow = quizInfo.answers[i][5]
    labelQuest.text = quizInfo.questions[i]
    labelL1.text = quizInfo.answers[i].text[1]
    labelL2.text = quizInfo.answers[i].text[2]
    labelR1.text = quizInfo.answers[i].text[3]
    labelR2.text = quizInfo.answers[i].text[4]
    
    backL1:addEventListener( "tap", checkCorrect )
    backL2:addEventListener( "tap", checkCorrect )
    backR1:addEventListener( "tap", checkCorrect )
    backR2:addEventListener( "tap", checkCorrect )
  end
  waitAnswer()
end

local function testsResponder(event)
  
  if ( event.isError)  then
    print( "Error!" )
  else
    local myNewData = event.response
    -- print("Server:"..myNewData)
    allQuiz = (json.decode(myNewData))
    -- print("Have tests")
    for k,v in pairs(news[1]) do
      print(k,v)
    end
    for i=1, #allQuiz do
      allQuiz[i].answers = json.decode(allQuiz[i].answers) 
      allQuiz[i].questions = json.decode(allQuiz[i].questions)
      allQuiz[i].praises = json.decode(allQuiz[i].praises)
    end
    news = allQuiz
    local newsGroup = display.newGroup()
    testsGroup:insert(newsGroup)

    local testHeight = 520
    for i=1, #news do
      local images = display.newRoundedRect(newsGroup, q.cx, 335+(i-1)*(testHeight+30), q.fullw-30*2,testHeight,12)
      images.anchorY = 0
      images.fill = c.gray
      images.i = i
      q.event.add("playtest"..i, images, startQuiz)
      q.event.group.add("testsButtons","playtest"..i)

      local paint = {
        type = "image",
        -- filename = "img/news_template.png"
        filename = "img/tests/"..i..".jpg"
      }
      images.fill = paint

      local front = display.newRoundedRect(newsGroup, q.cx, images.y+images.height, images.width,140,12)
      front.anchorY=1
      front.fill = c.gray2

      local frontUp = display.newRect(newsGroup, q.cx, front.y-front.height, images.width,front.height*.5)
      frontUp.anchorY=0
      frontUp.fill = c.gray2

      local newsLabel = display.newText({
        parent = newsGroup,
        text = news[i].title,
        x = 60,
        y = front.y - front.height*.5 - 25,
        font = "ubuntu_m.ttf",
        fontSize = 16*2,
        })
      newsLabel.anchorX = 0
      newsLabel:setFillColor( unpack( c.black ) )

      local dateLabel = display.newText({
        parent = newsGroup,
        text = news[i].date,
        x = 60,
        y = newsLabel.y+45,
        font = "roboto_r.ttf",
        fontSize = 13*2,
        })
      dateLabel.anchorX = 0
      dateLabel:setFillColor( unpack( q.CL"818C99" ) )
    end
    q.event.group.on("testsButtons")
    if #news>2 then
      maxUp = -(testHeight+30)*(#news-2)+160
      newsGroup:addEventListener("touch", scroll)
    end
    topMain:toFront()

    
  end
end

local function statisticResponder(event)
  if ( event.isError)  then
    print( "Error!" )
  else
    local myNewData = event.response
    local statAll = json.decode( myNewData )
    -- print("aaaaa",statAll["2"])
    local stat = statAll["1"]
    local grafInfo = statAll["2"]
    
    statGraf = {}
    local i = 0
    for k, v in pairs(grafInfo) do
      i = i + 1
      print(k,v)
      grafInfo[i] = json.decode( v )
      for k, v in pairs(grafInfo[i]) do
        print(k)
        if statGraf[k]==nil then
          print("new")
          statGraf[k]={1}
        else
          print("add")
          statGraf[k][#statGraf[k]+1]=1
        end
      end
      -- print( json.decode( v )["2022-05-04"])
    end
    print(#statGraf)

    for i=1, #grafInfo do

    end
    -- statGraf = grafInfo
    
    local sum = 0
    for i=1, #stat do
      sum = sum + stat[i]
    end
    local working = q.round(sum/#stat*100)
    local notWorking = 100 - working
    -- print("stat",#stat,sum)

    local workingLabel = display.newText({
      parent = adminGroup,
      text = "- Занятых "..working.."%",
      x=290,
      y=180,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
  workingLabel:setFillColor( unpack( c.black) )
  workingLabel.anchorX=0

  local notWorkingLabel = display.newText({
      parent = adminGroup,
      text = "- Безработных "..notWorking.."%",
      x=130,
      y=370,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
  notWorkingLabel:setFillColor( unpack( c.black) )
  notWorkingLabel.anchorX=0
    
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
local function changeResponder(event)
  if ( event.isError) then
    print( "Error!" )
  else
    myNewData = event.response
    print("Server:"..myNewData)

  end
end




function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

  testsGroup = display.newGroup()
  mainGroup:insert(testsGroup)

  kursGroup = display.newGroup()
  mainGroup:insert(kursGroup)
  kursGroup.alpha = 0

	eventGroup = display.newGroup()
	sceneGroup:insert(eventGroup)
	eventGroup.alpha = 0

	chatGroup = display.newGroup()
	sceneGroup:insert(chatGroup)
	chatGroup.alpha = 0

	profileGroup = display.newGroup()
	sceneGroup:insert(profileGroup)
	profileGroup.alpha = 0

  local account = q.loadLogin()
  if account.lic=="admin" then
    adminGroup = display.newGroup()
    sceneGroup:insert(adminGroup)
    adminGroup.alpha = 0
  end


	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	quizScreen = display.newGroup()
	uiGroup:insert(quizScreen)

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
  
  mainButton = display.newImageRect( uiGroup, "img/main.png", 58*2, 44*2 )
  mainButton.y = q.fullh - mainButton.height*.5-20
  mainButton.x = q.cx*.25+20
  mainButton:setFillColor( unpack( c.blue ) )
  mainButton:addEventListener( "tap", toMain )

  eventButton = display.newImageRect( uiGroup, "img/events.png", 58*2, 44*2 )
  eventButton.y = q.fullh - eventButton.height*.5-20
  eventButton.x = q.cx*.75+10
  eventButton:setFillColor( unpack( c.grayButtons ) )
  eventButton:addEventListener( "tap", toEvent )

  chatButton = display.newImageRect( uiGroup, "img/chatsoon.png", 58*2, 44*2 )
  chatButton.y = q.fullh - chatButton.height*.5-20
  chatButton.x = q.cx*1.25-10
  chatButton:setFillColor( unpack( c.gray ) )
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
  profileButton:addEventListener( "tap", toAccount )

  
  

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
      print("Serddder:",myNewData)
      local dataKurs = (json.decode(myNewData))
      
      local space = 70
      local testHeight = (q.fullw-3*space)*.5

      for i=1, #dataKurs do
        local images = display.newRoundedRect(kursGroup, q.cx*.55, 350+math.floor((i-1)/2)*(testHeight+150), testHeight, testHeight,12)
        images.anchorY = 0
        images.fill = c.gray
        images.i = i
        if i%2==0 then
          images.x = q.cx*1.45
        end

        local paint = {
          type = "image",
          -- filename = "img/kurs_template.png"
          filename = "img/kurses/"..i..".jpg"
        }
        images.fill = paint

        local discpriptionLabel = display.newText({
          parent = kursGroup,
          text = dataKurs[i].title,
          x = images.x-images.width*.5+10,
          y = images.y+images.width+15,
          width = testHeight-40,
          font = "poppins_m.ttf",
          fontSize = 12*2,
          })
        discpriptionLabel.anchorX = 0
        discpriptionLabel.anchorY = 0
        discpriptionLabel:setFillColor( unpack( c.black ) )

      end

    end
  end
  if isDevice then
    local data = q.getConnection("tests")
    kursesAdd({response=data})
  else
    network.request( "http://"..server.."/dashboard/kursesDownload.php", "GET",kursesAdd )
  end
	

	-- ========================
  -- ------------------------
  -- ========================

  local function newsAdd(event)
    if ( event.isError)  then
      print( "Error!" )
    else
      local myNewData = event.response
      print("Serddder:",myNewData)
      local realEvent = (json.decode(myNewData))
        
      local testHeight = 520
      local events = display.newGroup()
      eventGroup:insert(events)
      for i=1, #realEvent do

        local back = display.newRoundedRect(events, q.cx, 160+(i-1)*230, q.fullw-60, 200, 12)
        back.anchorY=0
        back.fill = c.gray2

        local newsLabel = display.newText({
          parent = events,
          text = realEvent[i].title,
          x = 60,
          y = back.y+back.height*.25+15,
          width = q.fullw-100,
          font = "ubuntu_m.ttf",
          fontSize = 16*2,
          })
        newsLabel.anchorX = 0
        newsLabel:setFillColor( unpack( c.black ) )

        local dateLabel = display.newText({
          parent = events,
          text = realEvent[i].datePost,
          x = 60,
          y = newsLabel.y+newsLabel.height,
          font = "roboto_r.ttf",
          fontSize = 13*2,
          })
        dateLabel.anchorX = 0
        dateLabel:setFillColor( unpack( q.CL"818C99" ) )
      end
      if account.lic=="admin" then
        local down = display.newRect(eventGroup, q.cx, q.fullh, q.fullw, 250)
        down.anchorY=1
        down.fill=c.gray

        local changeWorkButton, label = createButton(eventGroup, "СОЗДАТЬ НОВОСТЬ",q.fullh-150,"id")
      end
      -- q.event.group.on("testsButtons")
      if #realEvent>2 then
        -- maxUp = -(testHeight+30)*(#realEvent-2)+160
        -- events:addEventListener("touch", scroll)
      end
    end
  end
  if isDevice then
    -- local data = q.getConnection("tests")
    -- kursesAdd({response=data})
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

  -- local createButton(profileGroup, "ИЗМЕНИТЬ АВАТАРКУ",740,"id")
  local change = createButton(profileGroup, "СМЕНИТЬ ПАРОЛЬ",865-125,"id")
  local logOut = createButton(profileGroup, "ВЫЙТИ",865,"id")
  
  
  if account.lic=="user" then
    local changeWorkButton, label = createButton(profileGroup, account.working=="1" and "ПОТЕРЯЛ РАБОТУ" or "УСТРОИЛСЯ НА РАБОТУ",865+125,"id")
    changeWorkButton:addEventListener( "tap", function()
      changeWorkButton.fill = q.CL"4d327a"
      local r,g,b = unpack( c.blue )
      timer.performWithDelay( 400, 
      function()
        transition.to(changeWorkButton.fill,{r=r,g=g,b=b,time=300} )
      end)
      display.remove(label)
      local newText
      if account.working=="1" then
        account.working="0"
        newText = "УСТРОИЛСЯ НА РАБОТУ"
      else
        account.working="1"
        newText = "ПОТЕРЯЛ РАБОТУ"
      end
      label = textWithLetterSpacing( {
        parent = profileGroup, 
        text = newText, 
        x = changeWorkButton.x+changeWorkButton.width*.5, 
        y = changeWorkButton.y-changeWorkButton.height*.5, 
        font = "ubuntu_b.ttf", 
        fontSize = 14*2
        }, 10, .5)
      q.saveLogin(account)
      network.request( "http://"..server.."/dashboard/changeWork.php?email="..account.email, "GET", changeResponder )

    end )
  end

  logOut:addEventListener( "tap", function()
    q.saveLogin({})
    composer.gotoScene( "signin"  )
  end )

  change:addEventListener( "tap", function() 
    change.alpha=0
    logOut.alpha=0
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
    oldPass.placeholder = "Старый пароль"
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
      -- print("http://"..server.."/dashboard/changePassword.php?oldpassword="..oldPass.text.."&newpassword="..newPass.text.."&email="..account[1])
      network.request( "http://"..server.."/dashboard/changePassword.php?oldpassword="..oldPass.text.."&newpassword="..newPass.text.."&email="..account.email, "GET", changeResponder )
    end )

    local cancelButton = createButton(changeLayer, "ОТМЕНА",965+100-30,"cancelPass")
    cancelButton:addEventListener( "tap", function()
      display.remove(changeLayer)
      change.alpha=1
      logOut.alpha=1
    end )

    incorrectChange = display.newText({
      parent = changeLayer,
      text = "Ошибка!",
      x=50,
      y=cancelButton.y+50,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    incorrectChange:setFillColor( unpack( q.CL"e07682") )
    -- incorrectChange.anchorX=0
  end)



  if account.lic=="admin" then
    local adminBut = createButton(profileGroup, "АДМИН-МЕНЮ",865+125,"id")
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
      -- toKurs()
    toEvent()
		-- toChat()
    -- toAdmin()
	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
    composer.removeScene( "menu" )

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

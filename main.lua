local composer = require( "composer" )
composer.setVariable( "ip", "127.0.0.1" )

display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )



composer.gotoScene( "signin" )
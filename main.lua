-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local json     = require("json")
local widget   = require( "widget" )
local scrollView
local icons = {}

local oldFlag = nil
local function imageResult(event)
         if ( event.isError ) then
       print ( "Network error - download failed" )
   else
       if(oldFlag~= nil) 
        then
         oldFlag.x = -100
         display.remove(oldFlag)
        end
       event.target.alpha = 0
       event.target.x = display.contentCenterX
       event.target.y = display.contentCenterY
       transition.to( event.target, { alpha = 1.0 } )
       oldFlag = event.target
   end

   print ( "event.response.fullPath: ", event.response.fullPath )
   print ( "event.response.filename: ", event.response.filename )
   print ( "event.response.baseDirectory: ", event.response.baseDirectory )
  end  
  
local function iconListener( event )
   local id       = event.target.id
   local flag     = event.target.flag
   local flagName = event.target.flagName
   if ( event.phase == "moved" ) then
       local dx = math.abs( event.x - event.xStart ) 
       if ( dx > 5 ) then
           scrollView:takeFocus( event ) 
       end
   elseif ( event.phase == "ended" ) then
       --take action if an object was touched
       print( "object " .. flag, id, "was touched" )
       display.loadRemoteImage( flag, "GET", imageResult,flagName,system.TemporaryDirectory)
       timer.performWithDelay( 10, function() 
           if scrollView then
               scrollView:removeSelf()
               scrollView = nil
           end
       end )
   end
   return true
end

local function showSlidingMenu( response,request)
  -- if ( "ended" == event.phase ) then
if response == nil then
  return
 end
 
  if scrollView then
               scrollView:removeSelf()
               scrollView = nil
  end
  
       scrollView = widget.newScrollView
       {
           width = display.actualContentWidth - 20,
           height = 300,
           scrollWidth = display.actualContentWidth - 20,
           scrollHeight = 300,
           horizontalScrollDisabled = true
           --verticalScrollDisabled = true
       }
       scrollView.x = display.contentCenterX
       scrollView.y = 250
       local scrollViewBackground = display.newRect( (display.actualContentWidth) / 2, 2500, display.actualContentWidth, 5000 )
       scrollViewBackground:setFillColor( 0, 0, 0.2 )
       scrollView:insert( scrollViewBackground )
       --generate icons
       
       for i = 1, #response do
         --  icons[i] = display.newCircle( 50, i * 56, 22 )
         --  icons[i]:setFillColor( math.random(), math.random(), math.random() )
         --  scrollView:insert( icons[i] )
         --  icons[i].id = i
           icons[i] = display.newText( response[i].name.common, (display.actualContentWidth) / 2, i * 56,  native.systemFont, 30 )
           scrollView:insert( icons[i] )
           icons[i].id = i
           icons[i].flag = response[i].flags["png"]
           icons[i].flagName = request .. i .. ".png"
           icons[i]:addEventListener( "touch", iconListener )
       end
  -- end
  -- return true
end

local function networkJsonCall(path,value)
 
 print(path)
 local handleResponse = function(event)

   local printCommonNames = function(response,request)
     local count = #response
     -- for country = 1,#response do
     --  local name = response[country].name.common
     --  print(name)
     --  print(response[country].flags["png"])
     --  print(response[country].flags.svg)
     --  count = count  + 1
     -- end
  if count > 0 then

      showSlidingMenu(response,request)
   
   end
   
   end
   
   if not event.isError then
       local response = json.decode(event.response)
       if response~=nil 
        then
         printCommonNames(response,value)
        end
       --print( event.response )
   else
       print( "Error!" .. event)
   end

 end  
   
 network.request( path, "GET", handleResponse )
end 


local function textListener( event )
    local innerText = ""
      if ( event.phase == "began" ) then
        event.target.text = ""
          -- User begins editing "defaultBox"
      elseif ( event.phase == "ended" or event.phase == "submitted" ) then
          -- Output resulting text from "defaultBox"
          print( "---" .. event.target.text )
          innerText = event.target.text 
          innerText = innerText:gsub("%s+", "")
      elseif ( event.phase == "editing" ) then
          print( event.newCharacters )
          print( event.oldText )
          print( event.startPosition )
          print( event.text )
      end
   
      if(innerText:len() > 1 and innerText:match ("%d+") == nil) 
       then
         print(innerText)
         value = innerText
         
         networkJsonCall("https://restcountries.com/v3.1/name/" .. value,value)
       end  
  end
  
  
    local text = native.newTextField( display.contentCenterX, 50, display.actualContentWidth - 20, 50 )
    text.text = "Insert your country name"
    text.isEditable = true
    text:addEventListener( "userInput", textListener )

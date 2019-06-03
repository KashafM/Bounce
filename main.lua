-- variables
local paint = {0, 0, 0}
local paintWhite={1,1,1}
local paintRed={1,0,0}
local paintBlue={0,0,1}
local paintGreen={0,1,0}
local motionx = 0
math.randomseed( os.time() )
local weaponsX = math.random(20, 300)
dropInterval=math.random(800,2000)
local life1,life2,life3,life4
local lives=3
local playerSpeedCoefficient=1.2
local score=display.newText("", 0, 0, native.systemFont, 30)
local scoreText


display.setDefault("background", 1, 1, 1)
local weapons = display.newCircle(weaponsX, -20, 20)
life1=display.newCircle(20,0,10)
life2=display.newCircle(50,0,10)
life3=display.newCircle(80,0,10)
life4=display.newCircle(110,0,10)
life4.alpha=0
weapons.myName="weapons"
weapons.fill = paint
life1.fill=paintRed
life2.fill=paintRed
life3.fill=paintRed


local leftButton = display.newRect(display.contentWidth/4, display.contentHeight/2, display.contentWidth/2,display.contentHeight+90)
leftButton.alpha=0.01
leftButton.fill = paint
leftButton.strokeWidth = 3

local rightButton = display.newRect(display.contentWidth - display.contentWidth/4, display.contentHeight/2, display.contentWidth/2,display.contentHeight+90)
rightButton.alpha=0.01
rightButton.stroke = paint
rightButton.strokeWidth = 3

local ground = display.newRect(display.contentCenterX,display.contentHeight+2, display.contentWidth,70)
ground.fill = {0.1,0.1,0.1}

local player = display.newRect(display.contentCenterX, display.contentHeight - 60, 50, 50)
player.fill = paint

local physics = require("physics")
physics.start()
physics.setGravity(0, 5.1)
physics.addBody(weapons)
physics.addBody(player, "static")


local function dropWeapon( event )
local countPowerUp=math.random(1,10)
local randNum = math.randomseed( os.time() )
weaponsX = math.random(20, 300)
local weapons = display.newCircle(weaponsX, -20, 20)
--the probability of having a power-up is now 3/10 in total
if (countPowerUp==randNum) then
weapons.fill=paintWhite
weapons.myName="slow"
elseif (countPowerUp==8) then
weapons.fill=paintBlue
weapons.myName="life"
elseif (countPowerUp==randomNum) then
weapons.fill=paintGreen
weapons.myName="fasterPlayer"
else
weapons.fill = paint
weapons.myName="weapons"
end
physics.addBody(weapons)
dropInterval=math.random(800,2000)
end


--move player left or right
local function right()
motionx = 1
end
local function left ()
motionx = -1
end

--moving player function
local function movePlayer (event)
if ((player.x>30 and motionx==-1) or (player.x<display.contentWidth-30 and motionx==1)) then
player.x = player.x + playerSpeedCoefficient*motionx
end
end


local function resetPlayerSpeed ()
playerSpeedCoefficient=1.2
end

local function resetG()
physics.setGravity(0,5.1)
end


--scoring function. Gives the player 10 scores per second and 10 additional scores if a power-up's hit
local function scoring()
  display.remove(score)   --clean the previous score from the screen
  score = display.newText(math.round(system.getTimer()/1000), display.contentWidth-45, 0, native.systemFont, 27)
  score.fill = paintRed
end

--this timer drops "weapons" and power-ups
timer1=timer.performWithDelay( dropInterval, dropWeapon,0 )

--this timer performs the scoring
timer2=timer.performWithDelay( 100, scoring,0 )


-- check collision
local function onCollision(self, event)
if(event.phase == "began" and event.other.myName=="weapons") then
if (lives==4) then
life4.alpha=0
lives=3
event.other:removeSelf()
event.other=nil
elseif (lives==3) then
life3.alpha=0
lives=2
event.other:removeSelf()
event.other=nil
elseif (lives==2) then
life2.alpha=0
lives=1
event.other:removeSelf()
event.other=nil
elseif (lives==1) then
life1.alpha=0
physics.pause()
timer.cancel( timer1 )
timer.cancel( timer2 )
local display = display.newText("GAME LOST!", display.contentCenterX, display.contentCenterY - 40, native.systemFont, 30)
display.fill = {255, 0, 0}
motionx=0
rightButton:removeEventListener("tap", right)
leftButton:removeEventListener("tap", left)
end
--power-up for slowing the rate of falling is hit
elseif(event.phase == "began" and event.other.myName=="slow") then
physics.setGravity(0,1)
event.other:removeSelf()
event.other=nil
timer.performWithDelay( 6000, resetG,1)   --sets g value back after 6 seconds
scorePlus=10    --10 additional scores
--power-up for one additional life is hit
elseif(event.phase == "began" and event.other.myName=="life") then
if (lives==1) then
life2.alpha=1
life2.fill=paintRed
elseif (lives==2) then
life3.alpha=1
life3.fill=paintRed
elseif (lives==3) then
life4.alpha=1
life4.fill=paintRed
end
--can have up to 4 lives
if (lives<4) then
lives=lives+1
end
event.other:removeSelf()
event.other=nil
scorePlus=10
--power-up for moving player faster is hit
elseif(event.phase == "began" and event.other.myName=="fasterPlayer") then
event.other:removeSelf()
event.other=nil
playerSpeedCoefficient=3
timer.performWithDelay(6000, resetPlayerSpeed,1)
scorePlus=10
end
end

-- add eventlistener to code
rightButton:addEventListener("tap", right)
leftButton:addEventListener("tap", left)
player.collision = onCollision
player:addEventListener("collision")
Runtime:addEventListener("enterFrame", movePlayer)

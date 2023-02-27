Player = {}

function Player:load()
   self.x = 0
   self.y = 0
   self.width = 32
   self.height = 32
   self.xVel = 0
   self.yVel = 0

   --For width of frames
   self.frameWidth = 32
   
    -- Used to determine player on X
    -- In pixels: 200 / 4000 = 0.05 sec to go | 200 / 3500 = ~0.6 sec to stop
   self.maxSpeed = 200
   self.acceleration = 4000
   self.friction = 3500
   self.direction = "right"

    -- Used to determine player on Y
   self.gravity = 1500
   self.grounded = false
   self.jumpAmount = -500
   -- Counter to determine how many jumps and the max. num of jumps
   self.jumpCounter = 0
   self.maxJumps = 2

   -- Time manupulations
   self.elapsedTime = 0
   self.dtMULTIPLIER = 11

   --Frame Counters
   self.TOTALIDLEFRAMES = 11
   self.TOTALRUNFRAMES = 12
   self.TOTALJUMPFRAMES = 1
   self.TOTALDOUBLEJUMPFRAMES = 6
   self.TOTALFALLFRAMES = 1

   -- Load Player Grahpic
   self:loadAssets()

   self.physics = {}
-- Parameters: (Place to create body, x and y to create body at, what type of physical object either static,dynamic,kinematic)
   self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end



function Player:loadAssets()
   -- EACH ASSET NEEDS AN ATLAS AND ITS OWN QUAD TABLE!!!
   -- THEY ALSO NEED THEIR OWN ANIMATION FUNCTION AND DRAW FUNCTION
   self.idleAtlas = love.graphics.newImage("assets/Main Characters/Mask Dude/Idle (32x32).png")
   self.runAtlas = love.graphics.newImage("assets/Main Characters/Mask Dude/Run (32x32).png")
   self.jumpAtlas = love.graphics.newImage("assets/Main Characters/Mask Dude/Jump (32x32).png")
   self.doubleJumpAtlas = love.graphics.newImage("assets/Main Characters/Mask Dude/Double Jump (32x32).png")
   self.fallAtlas = love.graphics.newImage("assets/Main Characters/Mask Dude/Fall (32x32).png")
   self.idleFrames = {}  
   self.runFrames = {}
   self.jumpFrames = {}
   self.doubleJumpFrames = {}
   self.fallFrames = {}

   -- LOADS ASSETS FROM ATLAS TO {this}Frame table
   for i=0,self.TOTALIDLEFRAMES do
     table.insert(self.idleFrames, love.graphics.newQuad(i * self.frameWidth, self.y, self.width, self.height, self.idleAtlas:getDimensions()))
     self.idlecurrentFrame = i
   end
   for i=0,self.TOTALRUNFRAMES do
      table.insert( self.runFrames, love.graphics.newQuad(i * self.frameWidth, self.y, self.width, self.height, self.runAtlas:getDimensions()))
      self.runcurrentFrame = i
   end
   for i=0,self.TOTALJUMPFRAMES do
      table.insert(self.jumpFrames, love.graphics.newQuad(i * self.frameWidth, self.y, self.width, self.height, self.jumpAtlas:getDimensions()))
      self.jumpcurrentFrame = i
    end
    for i=0,self.TOTALDOUBLEJUMPFRAMES do
      table.insert(self.doubleJumpFrames, love.graphics.newQuad(i * self.frameWidth, self.y, self.width, self.height, self.doubleJumpAtlas:getDimensions()))
      self.doublejumpcurrentFrame = i
    end
    for i=0,self.TOTALFALLFRAMES do
      table.insert(self.fallFrames, love.graphics.newQuad(i * self.frameWidth, self.y, self.width, self.height, self.fallAtlas:getDimensions()))
      self.fallcurrentFrame = i
    end

   self.runFrame =  self.runFrames[self.runcurrentFrame]
   self.idleFrame = self.idleFrames[self.idlecurrentFrame]
   self.jumpFrame = self.jumpFrames[self.jumpcurrentFrame]
   self.doubleJumpFrame = self.doubleJumpFrames[self.doublejumpcurrentFrame]
   self.fallFrame = self.fallFrames[self.fallcurrentFrame]
end

function Player:idleAnim(dt)
   self.elapsedTime = self.elapsedTime + dt * self.dtMULTIPLIER
   if(self.elapsedTime > 1) then
      if(self.idlecurrentFrame < self.TOTALIDLEFRAMES) then
         self.idlecurrentFrame = self.idlecurrentFrame + 1
      else
         self.idlecurrentFrame = 1
      end
      self.idleFrame = self.idleFrames[self.idlecurrentFrame]
      self.elapsedTime = 0
   end
end

function Player:runAnim(dt)
   self.elapsedTime = self.elapsedTime + dt * self.dtMULTIPLIER
   if(self.elapsedTime > 1) then
      if( (self.runcurrentFrame < self.TOTALRUNFRAMES - 1) and self.grounded == true) then
         -- increases pace of frames
         self.runcurrentFrame = self.runcurrentFrame + 1
      else
         self.runcurrentFrame = 1
      end
      self.runFrame =  self.runFrames[self.runcurrentFrame]
      self.elapsedTime = 0
   end
end

function Player:jumpAnim(dt)
   self.elapsedTime = self.elapsedTime + dt * self.dtMULTIPLIER
   if(self.elapsedTime > 1) then
      if( (self.jumpcurrentFrame < self.TOTALJUMPFRAMES) and self.grounded == false) then
         -- increases pace of frames
         self.jumpcurrentFrame = self.jumpcurrentFrame
      else
         self.jumpcurrentFrame = 1
      end
      self.jumpFrame =  self.jumpFrames[self.jumpcurrentFrame]
      self.elapsedTime = 0
   end
end

--TODO: Figure out why this function goes out of bounds in frames table
function Player:doubleJumpAnim(dt)
   self.elapsedTime = self.elapsedTime + dt * self.dtMULTIPLIER
   if(self.elapsedTime > 1) then
      if( (self.doublejumpcurrentFrame < self.TOTALDOUBLEJUMPFRAMES) ) then
         -- increases pace of frames
         while(self.jumpCounter > 1) do
            self.doublejumpcurrentFrame = self.doublejumpcurrentFrame + 1
         end
      else
         self.doublejumpcurrentFrame = 1
      end
      self.doubleJumpFrame = self.doubleJumpFrames[self.doublejumpcurrentFrame]
      self.elapsedTime = 0
   end
end

function Player:fallAnim(dt)
   self.elapsedTime = self.elapsedTime + dt * self.dtMULTIPLIER
   if(self.elapsedTime > 1) then
      if( (self.fallcurrentFrame < self.TOTALFALLFRAMES) and (self.grounded == false and self.jumpAmount < 1)) then
         -- increases pace of frames
         self.fallcurrentFrame = self.fallcurrentFrame
      else
         self.jumpcurrentFrame = 1
      end
      self.fallFrame =  self.fallFrames[self.currentFrame]
      self.elapsedTime = 0
   end
end

function Player:update(dt)
   self:setDirection()
   self:syncPhysics()
   self:move(dt)
   self:applyGravity(dt)
   if (love.keyboard.isDown("d", "right") or love.keyboard.isDown("a", "left")) then
      self:runAnim(dt)
   elseif(love.keyboard.isDown("w", "up")) then
      self:jumpAnim(dt)
   elseif( (love.keyboard.isDown("w", "up") and self.jumpCounter > 1) ) then
      self.doubleJumpAnim(dt)
   else
      self:idleAnim(dt)
   end
end


function Player:applyGravity(dt)
   if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt
   end
end

function Player:setDirection()
   if self.xVel < 0 then
      self.direction = "left"
   else if self.xVel > 0 then
      self.direction = "right"
   end
   end
end

function Player:move(dt)
   if love.keyboard.isDown("d", "right") then
      if self.xVel < self.maxSpeed then
         if self.xVel + self.acceleration * dt < self.maxSpeed then
            self.xVel = self.xVel + self.acceleration * dt
         else
            self.xVel = self.maxSpeed
         end
      end
   elseif love.keyboard.isDown("a", "left") then
      if self.xVel > -self.maxSpeed then
         if self.xVel - self.acceleration * dt > -self.maxSpeed then
            self.xVel = self.xVel - self.acceleration * dt
         else
            self.xVel = -self.maxSpeed
         end
      end
   else
      self:applyFriction(dt)
   end
end

function Player:applyFriction(dt)
   if self.xVel > 0 then
      if self.xVel - self.friction * dt > 0 then
         self.xVel = self.xVel - self.friction * dt
      else
         self.xVel = 0
      end
   elseif self.xVel < 0 then
      if self.xVel + self.friction * dt < 0 then
         self.xVel = self.xVel + self.friction * dt
      else
         self.xVel = 0
      end
   end
end

function Player:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact(a, b, collision)
   if self.grounded == true then return end
   local nx, ny = collision:getNormal() --gets cords of unit vector from first to second obj. If b below a then y is pos. Oldest object is always a
   if a == self.physics.fixture then
      if ny > 0 then
         self:land(collision)
      end
   elseif b == self.physics.fixture then
      if ny < 0 then
         self:land(collision)
      end
   end
end

function Player:land(collision)
   self.currentGroundCollision = collision
   self.yVel = 0
   self.grounded = true
   self.jumpCounter = 0
end

function Player:jump(key)
   if (key == "w" or key == "up") and self.jumpCounter < self.maxJumps then
      self.jumpCounter = self.jumpCounter + 1
      self.yVel = self.jumpAmount
      self.grounded = false
   end
end

function Player:endContact(a, b, collision)
   if a == self.physics.fixture or b == self.physics.fixture then
      if self.currentGroundCollision == collision then
         self.grounded = false
      end
   end
end

function Player:draw()
  --Draws Idle Animation
   local scaleX = 1
   if self.direction == "left" then
      scaleX = -1
   end
   -- THIS IS Correct
  if ( (love.keyboard.isDown("d", "right") or love.keyboard.isDown("a", "left")) and self.grounded == true) then
   love.graphics.draw(self.runAtlas, self.runFrame, self.x, self.y - self.height + 15, 0, scaleX, 1, self.width / 2, 0)
  elseif (love.keyboard.isDown("w", "up")) then
   love.graphics.draw(self.jumpAtlas, self.jumpFrame, self.x, self.y - self.height + 15, 0, scaleX, 1, self.width / 2, 0)
  elseif ( (love.keyboard.isDown("w", "up") and self.jumpCounter > 1)) then
      love.graphics.draw(self.doubleJumpAtlas, self.doubleJumpFrame, self.x, self.y - self.height + 15, 0, scaleX, 1, self.width / 2, 0)  
   else
   love.graphics.draw(self.idleAtlas, self.idleFrame, self.x, self.y - self.height + 15, 0, scaleX, 1, self.width / 2, 0)
  end
end
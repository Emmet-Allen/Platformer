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
   self.idleAtlas = love.graphics.newImage("assets/Main Characters/Mask Dude/Idle (32x32).png")
   self.runAtlas = love.graphics.newImage("assets/Main Characters/Mask Dude/Run (32x32).png")
   self.frames = {}

   for i=0,self.TOTALIDLEFRAMES do
     table.insert(self.frames, love.graphics.newQuad(i * self.frameWidth, self.y, self.width, self.height, self.idleAtlas:getDimensions()))
     self.idlecurrentFrame = i
   end
   for i=1,self.TOTALRUNFRAMES do
      table.insert(self.frames, love.graphics.newQuad(i * self.frameWidth, self.y, self.width, self.height, self.runAtlas:getDimensions()))
      self.runcurrentFrame = i
   end
   self.runFrame = self.frames[self.runcurrentFrame]
   self.idleFrame = self.frames[self.idlecurrentFrame]
end

function Player:idleAnim(dt)
   self.elapsedTime = self.elapsedTime + dt * self.dtMULTIPLIER
   if(self.elapsedTime > 1) then
      if(self.idlecurrentFrame < self.TOTALIDLEFRAMES) then
         self.idlecurrentFrame = self.idlecurrentFrame + 1
      else
         self.idlecurrentFrame = 1
      end
      self.idleFrame = self.frames[self.idlecurrentFrame]
      self.elapsedTime = 0
   end
end

function Player:runAnim(dt)
   self.elapsedTime = self.elapsedTime + dt * self.dtMULTIPLIER
   if(self.elapsedTime > 1) then
      if(self.runcurrentFrame < self.TOTALRUNFRAMES - 1) then
         -- increases pace of frames
         self.runcurrentFrame = self.runcurrentFrame + 1
      else
         self.runcurrentFrame = 1
      end
      self.runFrame = self.frames[self.runcurrentFrame]
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
  if (love.keyboard.isDown("d", "right") or love.keyboard.isDown("a", "left")) then
   love.graphics.draw(self.runAtlas, self.runFrame, self.x, self.y - self.height + 15, 0, scaleX, 1, self.width / 2, 0)

  else
   love.graphics.draw(self.idleAtlas, self.idleFrame, self.x, self.y - self.height + 15, 0, scaleX, 1, self.width / 2, 0)
  end
end
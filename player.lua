Player = {}

function Player:load()
   self.x = 0
   self.y = 0
   self.width = 32
   self.height = 32
   self.xVel = 0
   self.yVel = 0

    -- Used to determine player on X
    -- In pixels: 200 / 4000 = 0.05 sec to go | 200 / 3500 = ~0.6 sec to stop
   self.maxSpeed = 200
   self.acceleration = 4000
   self.friction = 3500

    -- Used to determine player on Y
   self.gravity = 1500
   self.grounded = false
   self.jumpAmount = -500
   -- Counter to determine how many jumps and the max. num of jumps
   self.jumpCounter = 0
   self.maxJumps = 2

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
   love.graphics.setDefaultFilter('nearest', 'nearest')
   self.idleAtlas = love.graphics.newImage("assets/Main Characters/Ninja Frog/Idle (32x32).png")
   -- self.idleFrames = {}
   -- self.frameWidth = 32
   -- self.frameHeight = 32
   
   --for i=0,10 do
   --   table.insert(self.idleFrames, love.graphics.newQuad( i * self.frameWidth, self.y, self.frameWidth, self.frameHeight, self.idleAtlas:getWidth(), self.idleAtlas:getHeight() ))
   --   self.currentFrame = i
   --end
   -- self.idleSprite = love.graphics.newQuad(self.x, self.y, self.width, self.height, self.idleAtlas:getDimensions())
   -- self.idleFrames = {total = 11, current = 1, delay = 0.20, timePassed = 0}
   --  for frame = 1, self.idleFrames.current do
   --    --TODO: Figure out how quads work in animation https://sheepolution.com/learn/book/17
   --  self.idleFrames[frame] = love.graphics.newQuad( (frame + 1) * self.width,  0, self.width, self.height, self.idleAtlas:getDimensions())
   --  self.currentFrame = frame
   -- end
   self.frames = {}
   self.frames[1] = love.graphics.newQuad(self.x, self.y, self.width, self.height, self.idleAtlas:getDimensions())
   self.frames[2] = love.graphics.newQuad(32 , self.y, self.width, self.height, self.idleAtlas:getDimensions())
   self.frames[3] = love.graphics.newQuad(64, self.y, self.width, self.height, self.idleAtlas:getDimensions())
   self.frames[4] = love.graphics.newQuad(96 , self.y, self.width, self.height, self.idleAtlas:getDimensions())
   self.currentFrame = 1
   self.idleFrame = self.frames[self.currentFrame]

end

function Player:idleTime(dt)
   local elapsedTime = 0

   elapsedTime = elapsedTime + dt
   if(elapsedTime > 1) then
      if(self.currentFrame < 5) then
         self.currentFrame = self.currentFrame + 1
      else
         self.currentFrame = 1
      end
      self.idleFrame = self.frames[self.currentFrame]
      elapsedTime = 0
   end
end


function Player:update(dt)
   self:syncPhysics()
   self:move(dt)
   self:applyGravity(dt)
   self:idleTime(dt)
   --self.loadAssets.idleFrames.timePassed = self.loadAssets.idleFrames.timePassed + dt
end


function Player:applyGravity(dt)
   if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt
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
  -- love.graphics.draw(self.idleAnimation) --, self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  -- love.graphics.draw(self.idleAtlas, self.idleFrames[(self.currentFrame)], self.height, self.width)

  --Okay This Draws the FIRST FRAME! WOOOT
   love.graphics.draw(self.idleAtlas, self.idleFrame, self.x - self.width + 18, self.y - self.height + 15)
--Draws All Frames
--love.graphics.draw(self.idleAtlas, self.x - self.width + 18, self.y - self.height + 18) --, self.width, self.height)
end
local tiny = require("tiny")

local score = 0
local timer = 0

function collision(a, b)
    aw, ah = a.sprite:getDimensions()
    bw, bh = b.sprite:getDimensions()
    return a.x < (b.x + bw) and b.x < (a.x + aw) and a.y < (b.y + bh) and b.y < (a.y + ah)
end

local drawSystem = tiny.processingSystem()
drawSystem.filter = tiny.requireAll("sprite", "x", "y")
function drawSystem:process(e, dt)
    love.graphics.draw(e.sprite, e.x, e.y)
end

local playerSystem = tiny.processingSystem()
playerSystem.filter = tiny.requireAll("x", "y", "player")
function playerSystem:process(e, dt)
    local speed = 300
    if love.keyboard.isDown("right") then
        e.x = e.x + dt * speed
    elseif love.keyboard.isDown("left") then
        e.x = e.x - dt * speed
    end
end

local dropSystem = tiny.processingSystem()
dropSystem.filter = tiny.requireAll("sprite", "x", "y", "drop")
function dropSystem:process(e, dt)
    e.y = e.y + dt * 300
    if collision(player, e) then
        score = score + 1
        tiny.removeEntity(world, e)
    end
    if e.y > 500 then
        tiny.removeEntity(world, e)
    end
end

function spawnDrop(myworld, mysprite)
    tiny.addEntity(myworld, {
        sprite = mysprite,
        x = math.random(800),
        y = 0,
        drop = true
    })
end

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    bucket = love.graphics.newImage("sprites/bucket.png")
    drop = love.graphics.newImage("sprites/drop.png")
    player = {
        sprite = bucket,
        x = 300,
        y = 500 - 64,
        player = true
    }
    world = tiny.world(drawSystem, playerSystem, dropSystem, player)
end

function love.update(dt)
    if timer > 1 then
        spawnDrop(world, drop)
        timer = 0
    end
    world:update(dt)
    timer = timer + dt
end

function love.draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("Score: " .. tostring(score), 32, 32)
    love.graphics.setColor(1,1,1)
    drawSystem:update()
end

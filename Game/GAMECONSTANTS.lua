
-- 13.58.15.46

-- NETWORK CONSTANTS
SERVER_ADDRESS, SERVER_PORT = "104.131.9.165", nil
USERNAME = "Lane" -- Default
USERID = 54321 -- Default
UPDATERATE = 0.02

LOBBY_PORT = 5001


-- STRING CONSTANTS
PLAYER = "Player"
PEER = "Peer"
ENEMY = "Enemy"
PROJECTILE = "Projectile"
TERRAIN = "Terrain"
RANGED = "Ranged"
WEAPON = "Weapon"


-- Sprite String Constants
BASIC = "whiteguy"
DAMIAN = "damian"
DUSTIN = "dustin"
KARI = "kari"
LANE = "lane"




-- SPRITE CONSTANTS
spriteImg = love.graphics.newImage('images/sprites/player.png')
circleImg = love.graphics.newImage('images/sprites/Circle.png')
enemyImg = love.graphics.newImage('images/sprites/badguy.png')


CURRENTSPRITE = spriteImg
USERSPRITE = LANE


MENUMUSIC = love.audio.newSource("sounds/soundtrack/Menu.mp3")
WATERMUSIC = love.audio.newSource("sounds/soundtrack/Water.mp3")

MENUMUSIC:setLooping(true)
WATERMUSIC:setLooping(true)

WATERMUSIC:setVolume(.75)
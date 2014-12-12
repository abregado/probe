DEBUG_MODE = false


--global declarations
la = love.audio
lg = love.graphics
lm = love.mouse
lw = love.window
fs = love.filesystem
lp = love.physics

--requires
HC = require('HardonCollider')
vl = require ('hump-master/vector-light')
shapes = require ('HardonCollider.shapes')
gs = require('hump-master/gamestate')
list = require('buttonlist')
button = require('button')
tween = require('tween')
server = require('server')

--game entities
probeLogic = require('probe')



fonts = {}
fonts[1] = lg.newFont(10)
lg.setFont(fonts[1])

--graphics globals
screen = {w=lg.getWidth(),h=lg.getHeight()}

--gamestates
state={}
state.menu = require('state_menu')
state.game = require('state_game')

--graphics assets
as = {}


-- sounds globals

sfx = {}

currentTheme = 2

color = {}
color.menuBG = {125,125,255}
color.gameBG = {0,0,0}
color.ent = {0,255,0}
color.probe = {255,0,0}
color.alpha = {0,0,0,85}
color.white = {255,255,255}
color.weapons = {0,0,255}

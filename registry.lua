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
require('extraUtils')

server = require('server')
client = require('client')

--game entities
probeLogic = require('probe')
blast = require('blast')
missile = require('missile')
sigEnt = require('shipEnt')


fonts = {}
fonts[1] = lg.newFont(14)
fonts[2] = lg.newFont(25)
lg.setFont(fonts[1])

--graphics globals
screen = {w=lg.getWidth(),h=lg.getHeight()}

--gamestates
state={}
state.menu = require('state_menu')
state.game = require('state_game')
state.victory = require('state_victory')

--graphics assets
as = {}

--score
score = {}
score.torps = 0
score.probes = 0


-- sounds globals

sfx = {}

currentTheme = 2

color = {}
color.debug = {0,255,0}
color.path = {0,255,0,125}
color.menuBG = {125,125,255}
color.gameBG = {0,0,0}
color.ent = {0,255,0}
color.probe = {255,0,0}
color.alpha = {0,0,0,85}
color.white = {255,255,255}
color.black = {0,0,0}
color.weapons = {0,0,255}
color.probeCoverage={255,0,0,125}
color.scan = {255,0,0}
color.grid = {65,129,127}

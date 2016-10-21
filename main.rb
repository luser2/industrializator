require './gui.rb'
require './controls/command.rb'
require './controls/basic.rb'
require './world.rb'
require './buildings.rb'
require './turn.rb'
require './intro.rb'
require './research.rb'
require './road.rb'
require './war.rb'
$x=20
$y=20

intro

while true
  $World.draw
  c=getcmd
  Commands[c].act(true) if Commands[c]
end

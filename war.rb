require 'controls/battle.rb'

class Soldier
  def initialize(barracks)
    @barracks=barracks
    @training=0
    @weapon = nil
    @armor = nil
    @horse = nil
  end
  def progress
    if !@weapon
      if @barracks.resources[:bow] >= 5
	@weapon = :bow
	@barracks.resources[:bow] -= 5
      end
      if @barracks.resources[:stone_club] >= 5
	@weapon = :stone_club
	@barracks.resources[:stone_club] -= 5
      end
      @training = 0
    end
    if !@horse && @barracks.resources[:horse] >= 5
      @horse = true
      @barracks.resources[:horse] -= 5
      @training = 0
    end
    if @weapon != :bow && !@armor
      if @barracks.resources[:leather_armor] >= 5
        @armor = :leather_armor
        @barracks.resources[:leather_armor] -= 5
      end         
    end
    @training+=1
  end
end

class Unit
  attr_accessor :mode
  attr_accessor :x,:y,:range
  attr_accessor :hp,:mp,:maxmp
  attr_accessor :player,:soldiers,:attacked,:units
  def initialize(x,y,p,u)
    @x = x
    @y = y
    @range = 1
    @maxmp = 1
    @player = p
    @units = u
    startturn
  end
  def move(nx,ny)
	$battle.element[x,y]=?\ 
	$battle.element[nx,ny]=?@
	@x=nx
	@y=ny
	@mp -= 1
        $x = nx
        $y = ny
  end
  def canattack
    true
  end
  def attack
    @attacked = true
  end
  def startturn
	@mp = maxmp
	@mode = :move
	@attacked = false
	$x=x
	$y=y
  end
  def aiturn
    sx = sgn(units[0].x - x)
    sy = sgn(units[0].y - y)
    move(x + sx, y + sy) if $battle.element[x+sx,y+sy] == ?\ 
    $out.puts "#{units[0].x} #{x} #{sx} #{units.inspect}"
  end
end


def attackmenu
  country = nil
  neighbor = false
  (-1..1).each{|dx|
   (-1..1).each{|dy| 
     country = $World.player[$x+dx,$y+dy] if $World.player[$x+dx,$y+dy] != $World.player[$castle.x,$castle.y]
     neighbor = true  if $World.player[$x+dx,$y+dy] == $World.player[$castle.x,$castle.y]
  }}
  return if !country || !neighbor
  oldx = $x
  oldy = $y
  $x=0
  $y=0

  $battle = World.new("combat1.map")

  units = []
  units << Unit.new(3,3,0,units)
  units << Unit.new(8,8,1,units)

  endbattle = false
  p0units = 0
  p1units = 0
  units.each{|u|
	p0units+=1 if u.player == 0
	p1units+=1 if u.player == 1
  }

  i = 0
  units[0].startturn

  while (p0units > 0 && p1units > 0)
    nextunit = false
    $unit = units[i]
    if $unit.player == 0
      if $unit.mode == :move && $unit.mp == 0
        if $unit.canattack
          $unit.mode = :attack
        else
	  nextunit = true
        end
      else
	if $unit.attacked
	  nextunit = true
	end
      end
    else
      $unit.aiturn
      nextunit = true
    end

      Info.addstr(2,"moves: #{$unit.mp}/#{$unit.maxmp}")
      Info.addstr(3,"mode: #{$unit.mode}")
      Info.addstr(3,"mode: #{$unit.mode}")

      Info.refresh
      $battle.draw
    if nextunit
      i = (i + 1)% units.size
      $unit = units[i]
      $unit.startturn
    else
      c=getcmd
      BattleCommands[c].act(true) if BattleCommands[c]
    end
  end

  $x=oldx
  $y=oldy

  return if p0units == 0

  $World.win(country)

  if $World.player[42,12] == $World.player[$castle.x,$castle.y] && !Researched["has_horses"]
    stables = Stables.new 
    addbuilding(stables,45,7)
    addbuilding(Farm.new(),45,10)
    stables.resources[:horse]=30
    stables.resources[:food]=30

    Researched["has_horses"]=true
    popup("You conquered a tribe that breeds horses. Feed them to breed them. If you lose last horse you wont find them again.")
  end
end


require 'controls/battle.rb'

class Soldier
  def initialize(barracks)
    @barracks=barracks
    @training=0
    @weapon = nil
    @armor = nil
    @vehicle = nil
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
    if !@vehicle && @barracks.resources[:horse] >= 5
      @vehicle = :horse
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
  def mp
    return 2 if @vehicle == :horse
    return 1
  end
  def killed(enemy)
    true
  end
end

class Unit
  attr_accessor :mode
  attr_accessor :x,:y,:range
  attr_accessor :hp,:mp,:maxmp
  attr_accessor :player,:soldiers,:attacked,:units,:first_strike
  def initialize(x,y,p,u,soldiers)
    @x = x
    @y = y
    $battle.element[x,y]=?@
    @range = 1
    @maxmp = soldiers[0].mp
    @player = p
    @units = u
    @soldiers = soldiers
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
    units.each{|u|
      return u if (u.x-x)**2+(u.y-y)**2<=range && u.player != player
    }
    nil
  end
  def attack(u)
    @attacked = true
    v = self
    u, v = v, u if u.first_strike && !v.first_strike
    v.soldiers.each{|s|
      if u.soldiers[-1]
        u.soldiers.pop if s.killed(u.soldiers[-1])
      end
    }
    u.soldiers.each{|s|
      if v.soldiers[-1]
        v.soldiers.pop if s.killed(v.soldiers[-1])
      end
    }
    $battle.element[u.x,u.y]=?+ if !u.alive
    $battle.element[x,y]=?+ if !alive

  end
  def startturn
	@mp = maxmp
	@mode = :move
	@attacked = false
	$x=x
	$y=y
  end
  def aiturn
    target = nil
	$out.puts inspect
    units.each{|u|
	$out.puts u.inspect
	$out.puts u.alive
	$out.puts player
       target = u if u.alive && u.player != player 
    }
    return if !target
    sx = sgn(target.x - x)
    sy = sgn(target.y - y)
    move(x + sx, y + sy) if $battle.element[x+sx,y+sy] == ?\ 
    if canattack
      attack(canattack)
    end
  end
  def alive 
    @soldiers.size > 0
  end
end

def emptyleft
  100.times{|x|
  100.times{|y| return [x,y] if $battle.element[x,y]==?\ }}
end
def emptyright
  100.downto(0){|x|
  100.times{|y| return [x,y] if $battle.element[x,y]==?\ }}
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
  p0soldiers = []
  $buildings.each{|b|
    if b.is_a? Barracks
      p0soldiers += b.soldiers
    end
  }
  p0army = []
  p0soldiers.each{|s|
   x,y = *emptyleft
   p0army << Unit.new(x,y,0,units,[s])
  }


  p1soldiers=[Soldier.new(nil)]
  p1army = []
   p1soldiers.each{|s|
   x,y = *emptyright
   p1army << Unit.new(x,y,1,units,[s])
  }
 
 
  endbattle = false
  

  units.unshift(*p0army)
  units.unshift(*p1army)
  i = 0
  units[0].startturn
  p0units = 1
  p1units = 1
  $out.puts units.inspect
  while (p0units > 0 && p1units > 0)
    nextunit = false
    $unit = units[i]
    if $unit.alive
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
    else
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
    p0units = 0
    p1units = 0
    units.each{|u| 
	p0units+=1 if u.player == 0 && u.alive
	p1units+=1 if u.player == 1 && u.alive
    }
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


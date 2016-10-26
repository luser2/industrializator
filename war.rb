require 'controls/battle.rb'
$weapon_rating = {nil => 1, :stone_club => 2, :bow => 4}
$armor_rating = {nil => 0}
$weapon_range = {:bow => 6, :musket => 4}
$armor_piercing ={:musket =>true}
$explosive = {:granade =>true, :mortar=>true}


class Soldier
  attr_reader :weapon,:armor,:vehicle
  def initialize(barracks,w = nil, a = nil, v = nil)
    @barracks=barracks
    @training=0
    @weapon = w
    @armor = a
    @vehicle = v
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
  def range
    $weapon_range[@weapon] || 1
  end
  def ar
    if weapon == :bow
      p = [0.3,@training / 100.0].max
    else
      p = 0.3
    end 
    d = $weapon_rating[weapon]
    r = 0
    if $armor_piercing[weapon]
      r = d if rand() < 0.3
    else
      d.times{ r += 1 if rand() < p}
    end
    r
  end
  def dr
    d = $armor_rating[armor]
    d+= $armor_rating[weapon] if $armor_rating[weapon]
    d+= $armor_rating[vehicle] if $armor_rating[vehicle]
    r = 0
    d.times{ r += 1 if rand() < 0.3}
    r
  end

  def killed(enemy)
    return ar > enemy.dr
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
    @range = soldiers[0].range
    @maxmp = soldiers[0].mp
    @player = p
    @units = u
    @soldiers = soldiers
    startturn
    move(x,y)
  end
  def move(nx,ny)
	$battle.element[x,y]=?\ 

	$battle.element[nx,ny]=?@
        $battle.color[nx,ny]=color_pair(player == 0 ? COLOR_RED : COLOR_BLUE)|A_NORMAL
	@x=nx
	@y=ny
	@mp -= 1
        $x = nx
        $y = ny
  end
  def canattack
    units.each{|u|
      return u if (u.x-x)**2+(u.y-y)**2<=range**2 && u.player != player && u.alive
    }
    nil
  end
  def attack(u)
    @attacked = true
    v = self
    u, v = v, u if u.first_strike && !v.first_strike
    v.soldiers.each{|s|
      if u.soldiers[-1]
        ($explosive[s.weapon] ? u.soldiers.size : 1).times{
          u.soldiers.pop if s.killed(u.soldiers[-1])
        }
      end
    }
    u.soldiers.each{|s|
      if v.soldiers[-1] && (u.x-v.x)**2+(u.y-v.y)**2<=u.range**2
        if !$explosive[s.weapon]
          v.soldiers.pop if s.killed(v.soldiers[-1])
        end
      end
    }
    $battle.element[u.x,u.y]=?\  if !u.alive
    $battle.element[x,y]=?\  if !alive

  end
  def startturn
	@mp = maxmp
	@mode = :move
	@attacked = false
	$x=x
	$y=y
  end
  def bfs
    dir = Array2D.new
    stay = [x,y]
    visit =[[x+1,y],[x-1,y],[x,y+1],[x,y-1]]
    visit.each{|a| dir[*a]=a}
    i = 0
    while visit[i]
      x,y = *visit[i]
      units.each{|u|
        return dir[*visit[i]] if u.x == x && u.y == y && alive && player != u.player
      }
      if $battle.element[x,y]==?\ 
        [[-1,0],[1,0],[0,1],[0,-1]].each{|s| nx, ny= x + s[0], y + s[1]
          if !dir[nx,ny]
	    dir[nx,ny] = dir[x,y]
	    visit << [nx, ny]
 	  end
        }
      end
      i+=1
    end
    stay
  end

  def aiturn
    mp.times{
      nx, ny = *bfs
      move(nx, ny) if $battle.element[nx,ny] == ?\ 
    }
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

def soldiers_to_units(soldiers,coordinated,player,units)
  army = []
  u = []
  soldiers.sort_by{|s| "#{s.weapon} #{s.armor} #{s.vehicle}"}.each{|s|

   if u == []
     u = [s]
   elsif u.size < coordinated && u[0].weapon==s.weapon && u[0].armor == s.armor && u[0].vehicle == s.vehicle
    u << s
   else
     if player == 0
       x,y = *emptyleft
     else
      x,y = *emptyright
     end
     army << Unit.new(x,y,player,units,u)
     u = [s]
   end
  }
   if player == 0
     x,y = *emptyleft
   else
    x,y = *emptyright
   end
  army << Unit.new(x,y,player,units,u)
  $out.puts "army"
  $out.puts army.inspect
  return army
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
  $battle = World.new("combat1.map")

  units = []
  p0soldiers = []
  $buildings.each{|b|
    if b.is_a? Barracks
      p0soldiers += b.soldiers
    end
  }

  if  p0soldiers.size == 0
    popup("you don't have any army to attack with.")
    return
  end

  oldx = $x
  oldy = $y
  $x=0
  $y=0

  coordinated = 1
  coordinated += 1 if Researched["tactics"] 

  p0army = soldiers_to_units(p0soldiers,coordinated,0,units)

  $out.puts country
  $out.puts $defenders[country].inspect 
  $out.puts $defender_coordination[country]
  p1army = soldiers_to_units($defenders[country],$defender_coordination[country],1,units)
 
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
      if $unit.mode == :move && ($unit.mp == 0 || $unit.attacked)
	$unit.attacked = false
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


    info = $unit
    units.each{|u| info = u if u.x == $x && u.y == $y && u.alive}
    if info.alive
      Info.addstr(2,"moves: #{info.mp}/#{info.maxmp}")
      Info.addstr(3,"mode: #{info.mode}")
      Info.addstr(4,"soldiers: #{info.soldiers.size}")
      Info.addstr(5,"weapon: #{info.soldiers[0].weapon}")
      Info.addstr(6,"armor: #{info.soldiers[0].armor}")
      Info.addstr(7,"vehicle: #{info.soldiers[0].vehicle}")
    end


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

$defenders = {}
$defender_coordination = {}
c = $World.player[21,18]
$defenders[c] = [Soldier.new(nil)] * 2
$defender_coordination[c] = 1
c = $World.player[41,8]
$defenders[c] = [Soldier.new(nil,:stone_club,nil,:horse)] * 20
$defender_coordination[c] = 3
c = $World.player[77,7]
$defenders[c] = [Soldier.new(nil)] * 10
$defender_coordination[c] = 3
c = $World.player[77,21]
$defenders[c] = [Soldier.new(nil)] * 10
$defender_coordination[c] = 3


c = $World.player[40,1]
$defenders[c] = [Soldier.new(nil)] * 6
$defender_coordination[c] = 2
c = $World.player[54,1]
$defenders[c] = [Soldier.new(nil)] * 6
$defender_coordination[c] = 2
c = $World.player[68,1]
$defenders[c] = [Soldier.new(nil)] * 6
$defender_coordination[c] = 2
$out.puts "def"
$out.puts $defenders.inspect

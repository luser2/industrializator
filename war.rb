
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

def attackmenu
  country = nil
  neighbor = false
  (-1..1).each{|dx|
   (-1..1).each{|dy| 
     country = $World.player[$x+dx,$y+dy] if $World.player[$x+dx,$y+dy] != $World.player[$castle.x,$castle.y]
     neighbor = true  if $World.player[$x+dx,$y+dy] == $World.player[$castle.x,$castle.y]
  }}
  return if !country || !neighbor
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


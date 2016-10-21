class Building
  attr_accessor :display,:name,:cost
  attr_accessor :x, :y
  attr_accessor :resources
  attr_accessor :trade_from, :trade_to
  attr_accessor :max_population,:max_fuel,:horse_power
  def initialize(name,cost,trade_from,trade_to,display)
    @name=name
    @cost=cost
    @trade_from=trade_from
    @trade_to=trade_to
    @display=display
    @max_population = 1
    @resources=Hash.new{|h,k| h[k]=0}
  end
  def self.cost
    self.new.cost
  end
  def population
    food = [resources[:food],max_population].min
    food = max_population if @foodless
    food.times{
      beer_bonus=0
      return if !yield
      resources[:food]-=1 if !@foodless
      if resources[:beer]>0
        return if !yield
        resources[:beer]-=1
	beer_bonus=3
      end
      power_from = nil
      if @water_power
        power_from = :water
      elsif resources[:horse] > 0 && @horse_power
        power_from = :horse
      elsif @electronized
        power_from = :electricity if $electricity > 0
      elsif @steam_engine
        make_fuel
        power_from = :fuel if resources[:fuel] > 0 
      end

      if power_from
        return if !yield
        if power_from == :electricity
	  $electricity-=1
	elsif power_from = :water
          ;
        else
	  resources[power_from] -= 1
	end
        (2 + 3 * beer_bonus).times{return if !yield}
      end
    }
  end
  def make_fuel
    while resources[:fuel]<100 
       stop = true
       if resources[:wood]>0
         resources[:wood]-=1
         resources[:fuel]+=1
       elsif resources[:charcoal]>0
	 resources[:charcoal]-=1
         resources[:fuel]+=3
       elsif resources[:coal]>0
         resources[:coal]-=1
         resources[:fuel]+=10
       elsif $castle.resources[:electricity]>0
 	 $castle.resources[:electricity]-=1
	 resources[:fuel]+=1
       else
         break
       end
    end
  end
  def trade(from=trade_from,to=trade_to)
    last = nil
    amount = 0
    from.each{|r|
      if r == last
        amount +=1 
      else
        last = r
        amount = 1 
      end
      return false if resources[r]<amount
    }
    from.each{|r| resources[r] -= 1}
    to.each{|r| resources[r] += 1}
    return true
  end
end


class Prospector < Building
def initialize
 super("Prospector",{:stone=>10},[],[],"\
PP
PP")
end
  def produce
    population{resources[:progress]+=10}
    if resources[:progress]==100
      sx=self.x
      sy=self.y
      sellbuilding(self)
      
      atradius(10){|x,y|
        m = $World.minerals[sx+x,sy+y] 
        a = 
        if [?m,?M].index($World.element[sx+x,sy+y]) && !$World.building[sx+x,sy+y] && $World.minerals_amount[sx+x,sy+y]>0
	   if m == :coal
	     $World.element[sx+x,sy+y]=?c
	   elsif m == :copper
	     Msg.puts("copper and zinc you could research copper working") if !Researched["has_copper"]
	     Researched["has_copper"]=true
	     $World.element[sx+x,sy+y]=?C
	   elsif m == :zinc
	     Msg.puts("with copper and zinc you could research bronze working") if !Researched["has_zinc"]
	     Researched["has_zinc"]=true
	     $World.element[sx+x,sy+y]=?z
	  elsif m == :iron
	     Msg.puts("iron you could research iron working") if !Researched["has_iron"]
	     Researched["has_iron"]=true
	     $World.element[sx+x,sy+y]=?i
	   else
	     $World.element[sx+x,sy+y]=?m
	   end
        end
      }
      Msg.puts("You prospector finished his report and dismantled his camp.")
    end
  end
end

class Castle < Building


def produce
end
  def initialize
    super("Your castle",{},[],[],"\
/\\___/\\
|.....|
|o...o|
|..A..|
|__#__|")

    @resources[:wood]=100
  end
end



class University < Building
def initialize
  super("University",{:wood=>110},[],[:research],"\
 UUU
UUUUU
UOUOUUUU
UUUUUUUU
UU#UUUUU")
  @max_population = 5
end

def produce
  population{$castle.resources[:research]+=1}
end

end

class Dock < Building
def initialize
  super("Dock", {:stone=>50},[],[],"\
DDD
DDD
DDD")
end
end
class Wharf < Building
def initialize
  super("Wharf", {:stone=>50},[],[],"\
 W W
WWWWWW
 WWWW")
end
end



class Stables < Building
def initialize
  super("Stables", {:wood=>40},[],[:horse],"\
 SSS  
S   S
 S S")
end
def produce
  @active = true if resources[:horse] > 0
  if resources[:food] == 0
    resources[:horse] = 0
    @active = false 
  end
  if @active
    population{trade}
  end
end

end


class Barracks < Building
def initialize
  super("Barracks", {:wood=>40},[],[],"\
1 B 1
BB|BB
B_X_B")
end
end
class CartMaker < Building
def initialize
  super("Cart Maker", {:wood=>40},[],[],"\
  /\
|_##_|
|    |")
end
end


class Fletcher < Building
def initialize
  super("Fletcher", {:wood=>40},[:wood],[:bow],"\
  __
 /..\\
/____\\")
end

def produce
  population{trade}
end
end

class CharcoalMaker < Building
def initialize
  super("Charcoal Maker", {:stone=>30},[:wood],[:charcoal],"\
  ~~
 /\\
/##\\")
end

def produce
  population{trade}
end
end

class Smithy < Building
def initialize
  super("Smithy", {:stone=>30},[],[:tools,:weapons],"\
#####
####
 ##
####")
end
  def produce
    population{
      trade([:copper_ore,:wood],[:copper])||
      trade([:copper,:copper,:wood,:wood],[:tools])||
      trade([:bronze_ore,:charcoal],[:bronze])||
      trade([:bronze,:wood],[:tools])||
      trade([:iron,:wood],[:tools,:tools])

    }
  end
end


class Brewery < Building
def initialize
  super("Beer brewery", {:wood=>40},[:food,:fuel],[:beer,:beer,:beer],
" B--B
B..BbB
 B__B")
end
def produce
  make_fuel
  population{trade}
end
end


class Farm < Building
def initialize
  @foodless = true
  if Researched["plow"]
	@horse_power = true
  end
  if Researched["plow"]
 super("farm",{:wood=>30,:tools=>10},[],[:food],"\
FFFF
FooF
FooF
FFFF
")
  else
  super("big farm",{:wood=>30},[],[:food],"\
FFFFF
FoooF
FoooF
FoooF
FFFFF
")
  end
end
def produce
  population{trade}
end

end
$mine_modes=[:stone,:coal]
class Mine < Building
def initialize
  super("mine",{:wood=>20},[],[:stone,:coal,:iron_ore,:copper_ore,:zinc_ore],"\
/m
|m
mmmm")
@mode = 0
end
def resource_nearby
  atradius(5){|dx,dy|
    if [?c,?C,?z,?i,?m,?M].index($World.element[x+dx,y+dy]) && !$World.building[x+dx,y+dy]
      return true if $mine_modes[@mode] == :stone
      if [?c,?C,?z,?i].index($World.element[x+dx,y+dy]) && $World.minerals == $mine_modes[@mode]
        $World.minerals_amount[x+dx,y+dy]-=1
        $World.element[x,y] = ?m if $World.minerals_amount[x+dx,y+dy]==0
      end
    end
  }
  false
end
def produce
  population{
    if resource_nearby
      resources[$mine_modes[@mode]] +=1 
    else
      false
    end
  }
end
def next_mode
  @mode = (@mode + 1) % $mine_modes.size
end

end 


class Woodcutter < Building
def initialize
if Researched["saw"]
  super("woodcutter hut",{:tools=>20,:tools=>10},[],[:wood],"\
/WW\\
W__W")
else
  super("big woodcutter hut",{:wood=>20},[],[:wood],"\
/WWW\\
W...W
W___W")
end
@horse_power=true
end

def chop_tree
nearest = 100
nx=ny=0
(-10..10).each{|x1| cx = x + x1 + 2
(-10..10).each{|y1| cy = y + y1 + 1
  dist = x1**2+y1**2 + 0.01 * rand 
  if $World.element[cx , cy] == ?T && nearest > dist
    nearest = dist
    nx = cx
    ny = cy
  end
}
}
return false if nearest == 100
$World.element[nx,ny]=?\ 
$planttree<<[nx,ny]
true
end

def produce
  population{ chop_tree ? trade : false }
end

end

$planttree = []
100.times{|x| 100.times{|y|$planttree<<[x,y]}}

def grow_forest
  grow = []
  $planttree.uniq.each{|a| x,y=*a
    grow << [x,y] if $World.element[x,y]== ?\  && ($World.element[x-1,y] == ?T || $World.element[x+1,y] == ?T || $World.element[x,y-1] == ?T || $World.element[x,y+1] == ?T)
  }

  $planttree=[]
  grow.each{|a| x,y=*a
    if rand(10)==0
      $World.element[x,y]= ?\T
      $World.color[x,y]=color_pair(COLOR_GREEN)|A_NORMAL
      $planttree<<[x-1,y]
      $planttree<<[x+1,y]
      $planttree<<[x,y-1]
      $planttree<<[x,y+1]
    else
      $planttree<<[x,y]
    end
  }
end



def addbuilding(building,x,y)
   $buildings<<building
   building.display.split("\n").each_with_index{|e,y1|
     e.split("").each_with_index{|c,x1|
     if c != " "
       $World.element[x+x1,y+y1] = c[0]
       $World.building[x+x1,y+y1] = building
     end
   }}
  building.x=x
  building.y=y
end

def canbuild(building,x,y)
   return false if $World.player[x,y] != $World.player[$castle.x,$castle.y]
   building.display.split("\n").each_with_index{|e,y1|
     e.split("").each_with_index{|c,x1|
     return false if c != ?\ && $World.element[x+x1,y+y1] != ?\ 
  }}
  true
end

def buildmenu
if $trybuild
  if canbuild($trybuild,$x,$y)
    intro1 if $intro == 1 && $trybuild.class == Woodcutter
    intro3 if $intro == 3 && $trybuild.class == University

    addbuilding($trybuild,$x,$y)
    $trybuild = nil
  end
else
text = "what you want to build?\n"
canafford = []
$canbuild.each_with_index{|b,i|
item = "#{b.name}\t"
affordable=true
b.cost.each{|h,k| 
affordable = false if $castle.resources[h] < k
item+="#{h}: #{$castle.resources[h]}/#{k}\t"
}
canafford[i] = affordable
text << "#{(?a + i).chr}): #{item}\n" if affordable
text << "XX: #{item}\n" if !affordable
}
choice = popup(text) - ?a
return if !canafford[choice]
$trybuild = $canbuild[choice].new 
$trybuild.cost.each{|h,k| $castle.resources[h]-=k}
end
end

def sellbuilding(b = $World.building[$x,$y])
  if !b || b == $castle
    $World.element[$x,$y] = ?\  if [?<,?>,?^,?V].index($World.element[$x,$y])
    return
  end
  b.cost.each{|h,k| $castle.resources[h]+=k}

   b.display.split("\n").each_with_index{|e,y1|
     e.split("").each_with_index{|c,x1|
     if c != " "
       $World.element[b.x+x1,b.y+y1] = ?\ 
       $World.building[b.x+x1,b.y+y1] = nil
     end
   }}
  $buildings.delete(b)
end

$buildings=[]
$castle=Castle.new
addbuilding($castle,8,9)

$canbuild = [Farm,Woodcutter,University]
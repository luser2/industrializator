$outputs=[]
def addoutput(building,x,y)
  $outputs<<[building,x,y]
end
def moveitems
  12.times{
  $outputs.each{|o| building, x, y = *o
    if !$World.building[x,y]
      outbuilding = nil
      while outbuilding == nil
        e = $World.element[x,y]
        if $World.building[x,y]
          outbuilding = $World.building[x,y]
        elsif e==?<
          x-=1 
        elsif e==?>
          x+=1
        elsif e==?^
          y-=1 
        elsif e==?V
          y+=1 
        else
          outbuilding = false
        end
      end
      if outbuilding
        building.trade_to.each{|r|
          if (outbuilding == $castle || outbuilding.resources[r] < 100) && building.resources[r] > 0
             building.resources[r]-=1
             outbuilding.resources[r]+=1
          end
        }
      end
    end
  }
 }
end

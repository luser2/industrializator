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


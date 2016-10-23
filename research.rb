class Research
  attr_accessor :name,:func
  attr_accessor :cost
  attr_accessor :prereq
  def initialize(name,cost,prereq, &f)
    @name = name
    @cost = cost
    @prereq = prereq
    @func = f
  end
end
Researched={}
Researchs=[]
Researchs<<Research.new("brewing",100,[]){$canbuild << Brewery}
Researchs<<Research.new("warrior code",100,[]){$canbuild << Barracks}
Researchs<<Research.new("archery",200,["warrior code"]){$canbuild << Fletcher}
Researchs<<Research.new("horseback_riding",200,["warrior code","has_horses"]){$canbuild << Stables}
Researchs<<Research.new("wheel",200,["horseback_riding"]){$canbuild << CartMaker}

Researchs<<Research.new("sailing",100,[]){$canbuild << Wharf;$canbuild << Dock}
Researchs<<Research.new("trade",100,["sailing","currency"]){}

Researchs<<Research.new("navigation",100,["sailing"]){}

Researchs<<Research.new("mining",100,[]){$canbuild << Prospector; $canbuild << Mine}
Researchs<<Research.new("construction",100,["mining"]){}

Researchs<<Research.new("smelting",100,["mining"]){$canbuild << CharcoalMaker; $canbuild << Smithy}
Researchs<<Research.new("plow",100,["smelting"]){
  if $castle.resources[:tools] < 100
    $castle.resources[:research] += 100
    Researched["plow"]=false
    popup("you need 100 tools at castle as new farm requires tools to build")
  else
    $buildings.each{|b| sellbuilding(b) if b.class == Farm}
    popup("With plow you could make farms smaller, obsolete farms sold.")
  end
}
Researchs<<Research.new("saw",100,["smelting"]){
  if $castle.resources[:tools] < 100
    $castle.resources[:research] += 100
    Researched["saw"]=false

    popup("you need 100 tools at castle as new lumberjack requires tools to build")
  else
    $buildings.each{|b| sellbuilding(b) if b.class == Woodcutter}
    popup("With saw you could make lumberjack huts smaller, obsolete ones sold.")
  end
}
Researchs<<Research.new("anvil",100,["smelting"]){
  if $castle.resources[:tools] < 100
    $castle.resources[:research] += 100
    Researched["plow"]=false
    popup("you need 100 tools at castle as new smithy requires tools to build")
  else
  $buildings.each{|b| sellbuilding(b) if b.class == Smithy}
  popup("With anvil you could make smithies four times more effective, obsolete ones sold.")
  end
}

Researchs<<Research.new("currency",200,["mining","has_gold"]){$mine_modes<<:gold_ore}
Researchs<<Research.new("copper working",200,["mining","has_copper"]){$mine_modes<<:copper_ore}
Researchs<<Research.new("bronze working",200,["copper_working","smelting","has_zinc"]){$mine_modes<<:zinc_ore}
Researchs<<Research.new("iron working",200,["has_iron"]){$mine_modes<<:iron_ore; $canbuild << Foundry}
Researchs<<Research.new("steam_engine",200,["iron_working"]){$canbuild<<Factory}
Researchs<<Research.new("gunpowder",100,["bronze_working","has_saltpepper"]){}
Researchs<<Research.new("artillery",100,["gunpowder"]){}
Researchs<<Research.new("rifling",100,["gunpowder"]){}

Researchs<<Research.new("deep mining",100,["steam engine"]){}
Researchs<<Research.new("railroad",100,["steam engine"]){}
Researchs<<Research.new("ironclad",100,["steam engine"]){}
Researchs<<Research.new("refining",100,["steam engine"]){}
Researchs<<Research.new("plastic",100,["refining"]){}
Researchs<<Research.new("airship",100,["plastic"]){}

Researchs<<Research.new("fertilizer",100,["refining"]){}
Researchs<<Research.new("explosives",100,["refining","gunpowder"]){}
Researchs<<Research.new("automobile",100,["refining"]){}


Researchs<<Research.new("electricity",100,["steam engine"]){$canbuild<<PowerPlant}

Researchs<<Research.new("aluminium",100,["electricity"]){}
Researchs<<Research.new("computers",100,["electricity"]){}
Researchs<<Research.new("solar power",100,["electricity"]){}
Researchs<<Research.new("nuclear power",100,["has uran"]){}
Researchs<<Research.new("genetic engineering",100,["computers"]){}
Researchs<<Research.new("einstein's virus",100,["genetic engineering"]){}
Researchs<<Research.new("centaurs",100,["einstein's virus"]){}

Researchs<<Research.new("superbamboo",100,["genetic engineering"]){}
Researchs<<Research.new("hyperoats",100,["genetic engineering"]){}
Researchs<<Research.new("sugar virus",100,["superbamboo"]){}

Researchs<<Research.new("oil beet",100,["genetic engineering", "refining"]){}
Researchs<<Research.new("plastic yeast",100,["oil beet"]){}
Researchs<<Research.new("nitrobeans",100,["plastic yeast"]){}



Researchs<<Research.new("large hardron collidier",100,["computers"]){}
Researchs<<Research.new("time machine",100,["large hardron collidier"]){newgameplus}

Researchs<<Research.new("robotics",100,["computers"]){}
Researchs<<Research.new("nanomachines",100,["robotics"]){}
Researchs<<Research.new("nanosieve",100,["nanomachines"]){}

Researchs<<Research.new("special enchancement",100,["nanomachines"]){}

Researchs<<Research.new("laser",100,["robotics"]){}
Researchs<<Research.new("force field",100,["laser"]){}
Researchs<<Research.new("midichorians",100,["einstein's virus","force field","special enchancement"]){}
Researchs<<Research.new("lightsaber",100,["midichorians"]){}






IntroResearch={}
IntroResearch["brewing"] = "Now you can brew beer. That doubles quality of your life. Moreover it improves workforce, in a building when worker consumes food he converts resources into product. With a beer he does second conversion. These bonuses stack, with food and horse he works four times but if he has food, horse and beer he works eigth times. For brewing you need a fuel, you could use wood, charcoal or coal."
IntroResearch["mining"] = "Now you could build mine to get stone from ten tile radius to build better buildings. Find more natural riches by prospector which when feed finds all ores in radius ten.

Building modes:
Buildings like smithy or factory could produce different things based on its inputs. So can mine but changing mode is manual, press m while on mine to alternate between mining different resources.
"

IntroResearch["smelting"] = "When building wants fuel you could use different types. Starting with wood that serves as unit of fuel refining it into charcoal produces three units and coal 10 units. But wood doesn't produce high enough temperature for bronze where you need charcoal or coal and for iron coal. Note that coal is nonrenewable so you should be careful in managing it."

IntroResearch["large hardron collidier"] = "Time to travel time is near. You could send only microscopic object and your memories back. Next time you will start with all genetic and nanotechnology researches. By hitting Time travel research you will instantly travel back in time"

IntroResearch["warrior code"] = "You don't have enough lebensraum. You noticed that you don't fit many buildings in your kingdom. Build barracks and feed an army to get more space. Then press W to with cursor on neighbour's border (B tile) to attack him."

def researchmenu
  text = "Research\n"
  accessible = []
  Researchs.each{|r| prereq=true
    r.prereq.each{|p| prereq = false if !Researched[p]}
  
    if !Researched[r.name] && prereq
      text += "#{(?a + accessible.size).chr}): #{r.name} #{$castle.resources[:research]}/#{r.cost}\n" if $castle.resources[:research] >= r.cost
      text += "XX: #{r.name} #{$castle.resources[:research]}/#{r.cost}\n" if $castle.resources[:research] < r.cost
      accessible << r
    end
  }
  c = popup(text).ord - ?a
  r = accessible[c]
  if r && $castle.resources[:research] >= r.cost
    $castle.resources[:research] -= r.cost
    Researched[r.name]=true
    r.func.call
    popup(IntroResearch[r.name]) if IntroResearch[r.name]
  end
end

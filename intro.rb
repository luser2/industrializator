$intro = 0
def intro
    popup ("Goal: Build a university
As you don't remember details of technology you need  to make scientists research from high level directions. But you need to build university for them first.")


    popup ("Goal: Build a university
Step 1: Gather wood.
You don't have resources to build university. You need to build woodcutter to get wood. Press b to for build menu, select woodcutter and place it within 10 tiles from forest. When you placed it on empty space press b again (or x to cancel)")
$intro = 1
end

def intro1
 popup("Goal: Build a university
Step 2: Wood supply chain F>>>W>>>C
But villagers want food to work in your woodcutters hut. You need to build a farm. Then deliver it from farm to hut, then wood into the castle. Press r while centered in farm to start build road into woodcutters hut with arrow keys, then continue to castle. Press r again to stop building road.
")
$intro = 2
end

def intro2
 popup("Goal: Build a university
Step 3: Wait for resources.
Now you have chain to generate 1 wood/turn 
press enter for next turn
You want build more woodcutters to get resources faster. You could sell buildings at no cost by pressing s so optimal play involves building extra buildings, then selling them to get interest on wood.")
$intro=3
$intro_ecology=true
end
def intro3
popup("Goal: Research beer

Now you can fill upto five scientist to start research.

You could pursue several paths in research by pressing R. But from future knowledge the most important early research is beer as behavioural analysis found that villages paid by beer work twice as much which doubles production of most buildings.")
$intro = 4
end


def intro_ecology
 popup("Managing renewable resources.
Woodcutter cut a wood tile and some new wood tiles grew. While early you should aggressively cut wood you need to leave some for substainable economy.
")

$intro_ecology = false
end

class World
  attr_accessor :element,:building,:player,:minerals,:color
  def initialize(map="./world1.map")
     @player=Array2D.new
     @element=Array2D.new{?#}
     @minerals = Array2D.new
     @minerals_amount= Array2D.new{0}
     @minerals_amount_deep=Array2D.new{0}
     @color=Array2D.new{color_pair(COLOR_WHITE)|A_NORMAL}

     atradius(3){|x,y|
       @minerals[x+5,y+13]=:coal
       @minerals_amount[x+5,y+13]=100
     }
     atradius(3){|x,y|
       @minerals[x+17,y+16]=:copper
       @minerals_amount[x+5,y+13]=100
     }

     @building=Array2D.new
		x=y=0
		File.open(map){|f|
			while (c=f.getc)
				if c==?\n 
					@element[x,y]=?#
					x=0
					y+=1
				elsif c==?\r
					#windows
				else
					@element[x,y]=c
					@color[x,y]=color_pair(COLOR_GREEN)|A_NORMAL if c==?T
					x+=1
				end
			end
		}
    players=0
    @element.each_index{|e,x,y| 
	$out.puts "#{x} #{y} #{players}"

      if !@player[x,y]
	$out.puts "#{x} #{y} #{players}"
	players+=1
        playerdfs(players,x,y)
      end
    }
  end
  def playerdfs(color,x,y)
    return if @player[x,y]
    @player[x,y]=color
    return if [?#,?B].index(element[x,y])
    playerdfs(color,x,y+1)
    playerdfs(color,x,y-1)
    playerdfs(color,x+1,y)
    playerdfs(color,x-1,y)
  end
def win(country)
  pc = @player[$castle.x, $castle.y]
  @player.each_index{|e,x,y| @player[x,y] = pc if @player[x,y] == country}

  @player.each_index{|e,x,y| @element[x,y] = ?\ if @element[x,y] == ?B && @player[x,y]==pc && @player[x+1,y]==pc && @player[x-1,y]==pc && @player[x,y+1]==pc && @player[x,y-1]==pc}


end


  def draw
     Disp.wid.times{|x|
       Disp.hei.times{|y|
          if $x + x < Disp.wid/2 || y + $y < Disp.hei/2
            Disp.show(x,y,?#,@color[0,0])
          else
            Disp.show(x,y,@element[$x + x - Disp.wid/2,y + $y - Disp.hei/2],@color[$x + x - Disp.wid/2,y + $y - Disp.hei/2])
          end
       }
     }
     if $trybuild
       $trybuild.display.split("\n").each_with_index{|e,y1|
       e.split("").each_with_index{|c,x1|
        Disp.show(Disp.wid/2+x1,Disp.hei/2+y1,c[0],@color[0,0])
       }}
     else
       Disp.show(Disp.wid/2, Disp.hei/2,?X,@color[0,0])
     end
     Info.addstr(0,"x:#{$x}, y:#{$y}")
     Info.addstr(1,"")

     Info.addstr(1,building[$x,$y].resources.inspect) if building[$x,$y]
     Disp.refresh
     Info.refresh
  end
end
$World=World.new

require 'curses'
$roadmode=false
$trybuild=nil
class Move < Command
	def initialize(bi,nam,cor)
		super(bi,nam)
		@cord=cor
	end
	def act(who)

		if $roadmode && $World.building[$x,$y]
		  addoutput($World.building[$x,$y],$x+@cord[0],$y+@cord[1])
		end
		if $roadmode && $World.element[$x,$y]==?\ && !$trybuild && $World.player[$x,$y] == $World.player[$castle.x,$castle.y]
		   $World.element[$x,$y] = ?V if @cord == [0,1]
		   $World.element[$x,$y] = ?^ if @cord == [0,-1]
		   $World.element[$x,$y] = ?> if @cord == [1,0]
		   $World.element[$x,$y] = ?< if @cord == [-1,0]
                end
                if $World.element[$x + @cord[0],$y + @cord[1]] != ?#
		  $x += @cord[0]
		  $y += @cord[1]
		end
	end
end

dir=["up","down","left","right"]
cord=[[0,-1],[0,1],[-1,0],[1,0]]
bin=[Curses::KEY_UP,Curses::KEY_DOWN,Curses::KEY_LEFT,Curses::KEY_RIGHT]
4.times{|i|Move.new(bin[i],"move "+dir[i],cord[i]) }
def chrof(c)
	if c<256
		c.chr
	else
		"\\#{c}"
	end
end
Command.new(??,"help"){
	Commands.each{|b,cmd|Msg.puts "#{chrof(b)}: #{cmd.desc} " } 
}
Command.new(?i,"inspect"){ Msg.puts $World.building[$x,$y].resources.inspect if $World.building[$x,$y]
Msg.puts("x:#{$x} y:#{$y} p:#{$World.player[$x,$y]}")
}
Command.new(?r,"start/stop building roads"){
$roadmode=!$roadmode
intro2 if $intro == 2 && !$roadmode
}
Command.new(?d,"debug"){$castle.resources.each{|h,k| $castle.resources[h]+=100}}
Command.new(?q,"quit"){exit}
Command.new(Curses::KEY_NPAGE,"prev page"){Msg.pageup }
Command.new(Curses::KEY_PPAGE,"next page"){Msg.pagedown }
Command.new(?\n,"end turn"){newturn
intro3 if $intro == 3
}
Command.new(?m,"building mode"){
 $World.building[$x,$y].next_mode if $World.building[$x,$y].respond_to?(:next_mode)
}

Command.new(?b,"build"){buildmenu}
Command.new(?s,"sell"){sellbuilding}
Command.new(?R,"research"){researchmenu}
Command.new(?W,"attack"){attackmenu}
Command.new(?u,"upgrade"){$World.building[$x,$y].upgrade if $World.building[$x,$y]}

Command.new(?x,"cancel build"){sellbuilding($trybuild); $trybuild = nil}



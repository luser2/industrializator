require 'curses'
require 'util'
include Curses
init_screen
noecho
cbreak
stdscr.keypad=true
Curses.start_color
# Determines the colors in the 'attron' below
Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK) 
Curses.init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
Curses.init_pair(COLOR_WHITE,COLOR_WHITE,COLOR_BLACK)




class Gamewindow
	attr_accessor :wid,:hei
	def initialize(x1,y1,x2,y2)
		@wid=x2-x1
		@hei=y2-y1
		@curs=Window.new(@hei,@wid,y1,x1)
	end
end
class Displaywindow < Gamewindow
	attr_reader :color
	def initialize(*a)
		super(*a)
		@ar=Array2D.new
		@color=Array2D.new{A_NORMAL}
	end
	def show(x,y,c,cl)
		@ar[y,x]=c
		@color[y,x]=cl		
	end
	def refresh
		hei.times{|i|
                  s=""
                  color=@color[i,0]
		  @curs.setpos(i,0)
                  wid.times{|j|
		    if color != @color[i,j]
		      @curs.attron(color) 
                      @curs.addstr(s)
                      s=""
		      color = @color[i,j]
		    end
                    s+=(@ar[i,j] || ?\ ).chr if !@ar[i,j].is_a?(String)
                  }
                  @curs.attron(color) 
                  @curs.addstr(s)
                }
		@curs.refresh
		@ar=Array2D.new
	end
end
class Msgwindow < Gamewindow
	def initialize(*a)
		super(*a)
		@data=[""]*hei
		@pos=0
	end
	def puts(s)
		@pos+=1 if @data.size-@hei+1==@pos
		@data<< s
		refresh
	end
	def refresh
		5.times{|i|@curs.setpos(i,0);@curs.addstr(@data[@pos+(i-@hei)]+" "*(@wid-(@data[@pos+(i-@hei)] ).size ))}
		@curs.refresh
	end
	def pageup
		@pos=[@pos+@hei,@data.size-@hei+1].min
		refresh
	end
	def pagedown
		@pos=[@pos-@hei, 0].max
		refresh
	end
end
class Infowindow < Gamewindow
	def initialize(*a)
		super(*a)
		@data=[""]*hei
	end
	def addstr(i,str)
		@data[i]=str
	end
        def puts
          addstr(@data.size)
	end
	def refresh
		@data.size.times{|i|
                   @curs.setpos(i,0)
                   @curs.addstr(@data[i]+" "*([wid - @data[i].size,0].max))
                }
		@curs.refresh
	end
  def clear
    @data = []
  end
end
def getcmd
	Curses.getch
end
class Mapwindow < Displaywindow
end


def popup(msg)
  msg = msg.split("\n")
  popup = Infowindow.new(5,3,55,18)
  popup.clear
  msg.each_with_index{|m,i| popup.addstr(i,m)}
  popup.refresh
  c=getcmd
  Disp.refresh
  c
end

Map=Mapwindow.new(60,0,80,5)
Disp=Displaywindow.new(0,0,60,20)
Msg=Msgwindow.new(0,20,80,25)
Info=Infowindow.new(60,0,80,20)

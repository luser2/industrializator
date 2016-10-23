$out=File.open("./log","w")
class Array2D
	include Enumerable
	def initialize(&p)
		@ar=[]
		@pr=p
	end
	def [](x,y)
		@ar[x]||=[]
		@ar[x][y]||=@pr.call() if @pr
		@ar[x][y]
	end
	def []=(x,y,v)
		@ar[x]||=[]
		@ar[x][y]=v
	end
	def each(&p)
		@ar.each{|a| a.each(&p)}
	end
	def each_index(&p)
		@ar.size.times{|x| @ar[x].each_index{|y,e| p.call(e,x,y)} if @ar[x]}
	end
end

def atradius(rad)
	r=rad.to_i
	(2*r+1).times{|i|(2*r+1).times{|j|x=i-r;y=j-r
		yield(x,y) if x*x+y*y<=rad*rad
	}}
end

def sgn(x)
  return -1 if x<0
  return 1 if x>0
  return 0
end

Commands={}
class Command
	attr_accessor :desc
	def initialize(binding,des,&pr)
		@desc=des
		Commands[binding]=self
		@pro=pr
	end

	def act(who)
		@pro.call(who)
	end
end


require "rosace"

class Surnom < Rosace::Entity
	
	self.file = "regles/surnom.csv"

	# @!attribute [r] pers
	#  @return [Pers]
	reference :pers, :Pers, :required

	# @return [String] Surnom de {#pers}
	def value
		pers.commun
		super
	end

end
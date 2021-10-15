require "rosace"

class Surnom < Rosace::Entity
	
	self.file = "regles/surnom.csv"

	# @!attribute [r] value
	#  @return [String]

	# @!attribute [r] pers
	#  @return [Pers]
	reference :pers, :Pers, :required
	
end
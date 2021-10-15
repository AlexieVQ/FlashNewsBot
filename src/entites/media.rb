require "rosace"
require_relative "acteur"

class Media < Rosace::Entity

	include Acteur
	
	self.file = "regles/media.csv"

	TYPES = [:papier]

	# @!attribute [r] value
	#  @return [String]
	# @!attribute [r] nom
	#  @return [String]
	# @!attribute [r] pascal_case
	#  @return [String]

	# @!attribute [r] genre
	#  @return [:M, :F]
	enum :genre, *Acteur::GENRES

	# @!attribute [r] nombre
	#  @return [:S, :P]
	enum :nombre, *Acteur::NOMBRES

	# @!attribute [r] types
	#  @return [Array<Symbol>]
	mult_enum :types, *TYPES

	# @return [1, 2, 3]
	def personne
		3
	end
	
end
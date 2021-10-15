require "rosace"
require_relative "acteur"
require_relative "info"

class Pers < Rosace::Entity
	include Acteur
	self.file = "regles/pers.csv"

	# @!attribute [r] nom
	#  @return [String]
	# @!attribute [r] pascal_name
	#  @return [String]
	# @!attribute [r] cw
	#  @return [String]

	# @!attribute [r] genre
	#  @return [:M, :F]
	enum :genre, *Acteur::GENRES

	# @!attribute [r] nombre
	#  @return [:S, :P]
	enum :nombre, *Acteur::NOMBRES

	# @!attribute [r] categories
	#  @return [Array<Symbol>]
	mult_enum :categories, *Info::CATEGORIES

	# @!attribute [r] surnom
	#  @return [Surnom, nil]
	# @!attribute [r] surnom_list
	#  @return [Array<Surnom>]
	has_many :Surnom, :pers, :surnom

	# @return [void]
	def init
		# @type [Boolean]
		@nom_cite = false
	end

	# @return [String]
	def nom
		if !@nom_cite || surnom_list.empty?
			@nom_cite = true
			super
		else
			surnom.value
		end
	end

	# @return [1, 2, 3]
	def personne
		3
	end

	# @return [Integer]
	def qte
		super.to_i
	end

end
require "rosace"
require_relative "acteur"

class Lieu < Rosace::Entity

	include Acteur

	self.file = "regles/lieu.csv"

	TYPES = [
		"ville",
		"departement",
		"region",
		"etat",
		"pays",
		"union",
		"continent"
	]

	REGIMES = [
		"republique",
		"royaume",
		"dictature",
		"president",
		"chancelier",
		"parlement"
	]

	# @!attribute [r] nom
	#  @return [String]
	# @!attribute [r] nom_en
	#  @return [String]
	# @!attribute [r] pascal_case
	#  @return [String]
	# @!attribute [r] adj_ms
	#  @return [String]
	# @!attribute [r] adj_fs
	#  @return [String]
	# @!attribute [r] adj_mp
	#  @return [String]
	# @!attribute [r] adj_fp
	#  @return [String]

	# @!attribute [r] genre
	#  @return [:M, :F]
	enum :genre, *Acteur::GENRES

	# @!attribute [r] nombre
	#  @return [:S, :P]
	enum :nombre, *Acteur::NOMBRES

	# @!attribute [r] parent
	#  @return [Lieu, nil]
	reference :parent, :Lieu, :optional

	# @!attribute [r] type
	#  @return [Symbol]
	enum :type, *TYPES

	# @!attribute [r] regime
	#  @return [Array<Symbol>]
	mult_enum :regime, *REGIMES

	# @return [String]
	def code
		c = super
		if c.empty? && parent
			parent.code
		else
			c
		end
	end

	# @return [String]
	def emoji
		e = super
		if e.empty? && parent
			parent.emoji
		else
			e
		end
	end

	# @return [Lieu, nil]
	def pays
		if type == :pays
			self
		elsif parent
			parent.pays
		else
			nil
		end
	end

	# @return [3]
	def personne
		3
	end

	# @return [Integer]
	def qte
		1000
	end

end
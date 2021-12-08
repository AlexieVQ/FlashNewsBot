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
		"parlement",
		"empire"
	]

	# @!attribute [r] nom
	#  @return [String]
	# @!attribute [r] nom_en
	#  @return [String]
	# @!attribute [r] pascal_case
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

	# @return [Boolean]
	def pick?(*args)
		args.empty? || args.any? do |arg|
			arg.to_sym == type || arg == "paradis_fiscal" && paradis_fiscal
		end
	end

	# @return [String] Code à deux signes du lieu ou d'un parent.
	def code2
		c = super
		if c.empty? && parent
			parent.code2
		else
			c
		end
	end

	# @return [String] Code à trois signes du lieu ou d'un parent.
	def code3
		c = super
		if c.empty? && parent
			parent.code3
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

	# @return [Boolean]
	def paradis_fiscal
		super.to_i == 1
	end

	# Gentilé du lieu.
	# @param genre [#to_sym] Genre de l'adjectif
	# @param nombre [#to_sym] Nombre de l'adjectif
	# @return [String] Gentilé du lieu
	def adj(genre = :M, nombre = :S)
		self.genre_adj = genre.to_sym
		self.nombre_adj = nombre.to_sym
		super()
	end

	# Définit les formes différentes d'{adj} selon le genre et le nombre
	# @param ms [String] Masculin singulier
	# @param fs [String] Féminin singulier
	# @param mp [String] Masculin pluriel
	# @param fp [String] Féminin pluriel
	# @return [String] Forme correspondant au genre et au nombre courent
	def defgn(ms, fs, mp, fp)
		if genre_adj == :M
			if nombre_adj == :S
				ms
			else
				mp
			end
		else
			if nombre_adj == :S
				fs
			else
				fp
			end
		end
	end

	private

	# @return [:M, :F] Genre courent de l'adjectif
	attr_accessor :genre_adj

	# @return [:S, :P] Nombre courent de l'adjectif
	attr_accessor :nombre_adj

end
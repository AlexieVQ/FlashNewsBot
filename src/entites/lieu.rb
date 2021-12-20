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
		"royaume",
		"dictature",
		"president",
		"chancelier",
		"parlement",
		"empire",
		"emirat",
		"saint_siege",
		"principaute",
		"grand_duche",
		"guide_supreme"
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

	# @return [Integer] Poids du lieu dans les choix aléatoires
	def weight
		poids = super
		# @type [Info]
		info = context.variable(:$info)
		if info
			if info.lieux(multi_niveaux: false).any? { |lieu| lieu == self }
				return 1
			end
			# @type [#origine, nil]
			sujet = info.instance_variable_get(:@sujet)
			if sujet.respond_to?(:origine) && parent?(sujet.origine)
				poids *= 100
			end
		end
		poids
	end

	# Teste si +self+ est un parent (direct ou indirect) du lieu donné
	# @param lieu [Lieu] lieu enfant potentiel
	# @return [Boolean] Vrai si ce lieu est un parent du lieu donné
	def parent?(lieu)
		if self == lieu
			true
		elsif parent.nil?
			false
		else
			parent.parent?(lieu)
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

	# Similaire à `.defgn(,e,s,es)`
	# @see #defgn
	def defes
		defgn("", "e", "s", "es")
	end

	# Similaire à `.defgn(,e,,es)`
	# @see #defgn
	def defs
		defgn("", "e", "", "es")
	end

	# Similaire à `.defgn(,ne,s,nes)`
	# @see #defgn
	def defnes
		defgn("", "ne", "s", "nes")
	end

	# Retourne la fonction du chef de l'exécutif de ce lieu.
	#
	# S’applique aux villes (maire), départements (président du conseil
	# départemental) et aux lieux ayant des régimes spécifiés.
	# @param genre ["M", "F", :M, :F] genre de la personne
	# @param nombre ["S", "P", :S, :P] nombre de personnes
	# @return [String, nil] la fonction, ou +nil+ si ce
	#  n'est pas applicable pour ce lieu.
	def chef(genre = :M, nombre = :S)
		f = ->(ms, fs, mp, fp) do
			if genre.to_sym == :M
				if nombre.to_sym == :S
					ms
				else
					mp
				end
			else
				if nombre.to_sym == :S
					fs
				else
					fp
				end
			end
		end
		# @type [Array<String>]
		fonctions = regime.map do |regime|
			case regime
			when :royaume
				f("roi", "reine", "rois", "reines")
			when :dictature
				f("dictateur", "dictatrice", "dictateurs", "dictatrice")
			when :president
				f("président", "présidente", "présidents", "présidentes")
			when :chancelier
				f("chancelier", "chancelière", "chanceliers", "chancelières")
			when :parlement
				f("premier ministre", "première ministre", "premiers ministres",
						"premières ministres")
			when :empire
				f("empereur", "impératrice", "empereurs", "impératrices")
			when :emirat
				f("émir", "émiresse", "émirs", "émiresses")
			when :saint_siege
				f("pape", "papesse", "papes", "papesses")
			when :principaute
				f("prince", "princesse", "princes", "princesses")
			when :grand_duche
				f("grand duc", "grande duchesse", "grands ducs",
						"grandes duchesses")
			when :guide_supreme
				f("guide suprême", "guide suprême", "guides suprêmes",
						"guides suprêmes")
			else
				raise "Régime inconnu #{regime}"
			end
		end
		case type
		when :ville
			fonctions << f("maire", "maire", "maires", "maires")
		when :departement
			fonctions << f("président", "présidente", "présidents",
					"présidentes") + " du conseil départemental"
		end
		fonctions.empty? ? nil : fonctions[rand(fonctions.length)]
	end

	private

	# @return [:M, :F] Genre courent de l'adjectif
	attr_accessor :genre_adj

	# @return [:S, :P] Nombre courent de l'adjectif
	attr_accessor :nombre_adj

end
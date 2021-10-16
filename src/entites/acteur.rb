require_relative "../refinements"

module Acteur

	using Refinements

	GENRES = [:M, :F]
	NOMBRES = [:S, :P]

	# @return [Acteur]
	def self.new(nom:, genre: :M, nombre: :S, personne: 3)
		Class.new do
			include Acteur

			def initialize(nom, genre, nombre, personne)
				@nom = nom
				@genre = genre
				@nombre = nombre
				@personne = personne
			end

			def nom
				@nom
			end

			def genre
				@genre
			end

			def nombre
				@nombre
			end

			def personne
				@personne
			end
		end.new(nom, genre, nombre, personne)
	end

	# @!attribute [r] genre
	#  @return [:M, :F]
	# @!attribute [r] nombre
	#  @return [:S, :P]
	# @!attribute [r] personne
	#  @return [1, 2, 3]
	
	# @param masc [String]
	# @param fem [String]
	# @return [String]
	def g(masc, fem)
		self.genre == :F ? fem : masc
	end

	# @param sing [String]
	# @param plur [String]
	# @return [String]
	def n(sing, plur)
		self.nombre == :P ? plur : sing
	end

	# @param p1 [String]
	# @param p2 [String]
	# @param p3 [String]
	# @return [String]
	def p(p1, p2, p3)
		case self.personne
		when 1
			p1
		when 2
			p2
		else
			p3
		end
	end

	# @param ms [String]
	# @param fs [String]
	# @param mp [String]
	# @param fp [String]
	# @return [String]
	def gn(ms, fs, mp, fp)
		self.n(self.g(ms, fs), self.g(mp, fp))
	end

	# @param s1 [String]
	# @param s2 [String]
	# @param s3 [String]
	# @param p1 [String]
	# @param p2 [String]
	# @param p3 [String]
	# @return [String]
	def pn(s1, s2, s3, p1, p2, p3)
		self.n(self.p(s1, s2, s3), self.p(p1, p2, p3))
	end

	# @return [String]
	def s
		self.n("", "s")
	end

	# @return [String]
	def es
		self.gn("", "e", "s", "es")
	end

	def implicite?
		[1, 2].include?(personne) || @_acteur_nom_cite
	end

	# @return [String]
	def sujet_explicite
		# @type [Boolean]
		@_acteur_nom_cite = true
		self.nom
	end

	# @return [String]
	def tonique_explicite
		@_acteur_nom_cite = true
		self.nom
	end

	# @return [String]
	def cod_explicite
		@_acteur_nom_cite = true
		self.nom
	end

	# @return [String]
	def coi_explicite
		@_acteur_nom_cite = true
		match = /\A\s*(?<article>(le |les )?)(?<nom>.*)\z/i.match(self.nom)
		if /\Ale \z/i =~ match[:article] 
			"au " + match[:nom]
		elsif /\Ales \z/i =~ match[:article]
			"aux " + match[:nom]
		else
			"à " + match[:nom]
		end
	end

	# @return [String]
	def comp_explicite
		@_acteur_nom_cite = true
		match = /\A\s*(?<article>(le |les )?)(?<nom>.*)\z/i.match(self.nom)
		if /\Ale \z/i =~ match[:article]
			"du " + match[:nom]
		elsif /\Ales \z/i =~ match[:article]
			"des " + match[:nom]
		else
			(match[:nom].voyelle? ? "d’" : "de ") + match[:nom]
		end
	end

	# @param verbe [String]
	# @return [String]
	def sujet_implicite(verbe = "")
		if verbe.empty?
			self.pn(
				"je",
				"tu",
				self.g("il", "elle"),
				"nous",
				"vous",
				self.g("ils", "elles")
			)
		else
			self.pn(
				(verbe.voyelle? ? "j’" : "je ") + verbe,
				"tu " + verbe,
				self.g("il ", "elle ") + verbe,
				"nous " + verbe,
				"vous " + verbe,
				self.g("ils ", "elles ") + verbe
			)
		end
	end

	# @param verbe [String]
	# @return [String]
	def sujet_inverse_implicite(verbe)
		dt = /[dt]/i =~ verbe[-1]
		self.pn(
			verbe + "-je",
			verbe + "-tu",
			verbe + (dt ? self.g("-il", "-elle") : self.g("-t-il", "-t-elle")),
			verbe + "-nous",
			verbe + "-vous",
			verbe + (dt ?
				self.g("-ils", "-elles") :
				self.g("-t-ils", "-t-elles")
			)
		)
	end

	# @return [String]
	def tonique_implicite
		self.pn(
			"moi",
			"toi",
			self.g("lui", "elle"),
			"nous",
			"vous",
			self.g("eux", "elles")
		)
	end

	# @param verbe [String]
	# @return [String]
	def cod_implicite(verbe)
		v = verbe.voyelle?
		self.pn(
			(v ? "m’" : "me ") + verbe,
			(v ? "t’" : "te ") + verbe,
			(v ? "l’" : self.g("le ", "la ")) + verbe,
			"nous " + verbe,
			"vous " + verbe,
			"les " + verbe
		)
	end

	# @param verbe [String]
	# @return [String]
	def coi_implicite(verbe)
		v = verbe.voyelle?
		self.pn(
			(v ? "m’" : "me ") + verbe,
			(v ? "t’" : "te ") + verbe,
			"lui " + verbe,
			"nous " + verbe,
			"vous " + verbe,
			"leur " + verbe
		)
	end

	# @param nom [String]
	# @return [String]
	def comp_implicite(nom)
		match = /\A\s*(?<pre>(à |de )?)(?<article>(le |la |les |l’|au |aux |du |un |une |des )?)(?<nom>.*)\z/i.match(nom)
		if /\A(le |l’)\z/i =~ match[:article]
			match[:pre] + self.pn(
				"mon ",
				"ton ",
				"son ",
				"notre ",
				"votre ",
				"leur "
			) + match[:nom]
		elsif /\Ala \z/i =~ match[:article]
			match[:pre] + self.pn(
				"ma ",
				"ta ",
				"sa ",
				"notre ",
				"votre ",
				"leur "
			) + match[:nom]
		elsif /\Ales \z/i =~ match[:article]
			match[:pre] + self.pn(
				"mes ",
				"tes ",
				"ses ",
				"nos ",
				"vos ",
				"leurs "
			) + match[:nom]
		elsif /\Aau \z/i =~ match[:article]
			match[:pre] + self.pn(
				"à mon ",
				"à ton ",
				"à son ",
				"à notre ",
				"à votre ",
				"à leur "
			) + match[:nom]
		elsif /\Aaux \z/i =~ match[:article]
			match[:pre] + self.pn(
				"à mes ",
				"à tes ",
				"à ses ",
				"à nos ",
				"à vos ",
				"à leurs "
			) + match[:nom]
		elsif /\Adu \z/i =~ match[:article]
			match[:pre] + self.pn(
				"de mon ",
				"de ton ",
				"de son ",
				"de notre ",
				"de votre ",
				"de leur "
			) + match[:nom]
		elsif /\A(un|une|des) \z/i =~ match[:article]
			nom + self.pn(
				" à moi",
				" à toi",
				self.g(" à lui", " à elle"),
				" à nous",
				" à vous",
				self.g(" à eux", " à elles")
			)
		else
			nom + " " + self.comp_implicite
		end
	end

	# @param verbe [String]
	# @return [String]
	def sujet(verbe)
		if implicite?
			self.sujet_implicite(verbe)
		else
			self.sujet_explicite + " " + verbe
		end
	end

	# @param verbe [String]
	# @param participe [String]
	# @return [String]
	def sujet_inverse(verbe, participe = "")
		if implicite?
			self.sujet_inverse_implicite(verbe) +
				(participe.empty? ? "" : " " + participe)
		elsif participe.empty?
			verbe + " " + self.sujet_explicite
		else
			verbe + " " + participe + " " + self.sujet_explicite
		end
	end

	# @return [String]
	def tonique
		if implicite?
			self.tonique_implicite
		else
			self.tonique_explicite
		end
	end

	# @return [String]
	def vocatif
		@_acteur_nom_cite = true
		self.nom.gsub(/\A(le |la |les |l’|un |une |des )/i, "")
	end

	# @param verbe [String]
	# @return [String]
	def cod(verbe)
		if implicite?
			self.cod_implicite(verbe)
		else
			verbe + " " + self.cod_explicite
		end
	end

	# @param verbe [String]
	# @return [String]
	def coi(verbe)
		if implicite?
			self.coi_implicite(verbe)
		else
			verbe + " " + self.coi_explicite
		end
	end

	# @param nom [String]
	# @return String
	def comp(nom)
		if implicite?
			self.comp_implicite(nom)
		else
			nom + " " + self.comp_explicite
		end
	end

	# @return [String]
	def a
		self.pn(
			"ai",
			"as",
			"a",
			"avons",
			"avez",
			"ont"
		)
	end

	# @return [String]
	def est
		self.pn(
			"suis",
			"es",
			"est",
			"sommes",
			"êtes",
			"sont"
		)
	end

	# @return [String]
	def avait
		self.pn(
			"avais",
			"avais",
			"avait",
			"avions",
			"aviez",
			"avaient"
		)
	end

	# @return [String]
	def etait
		self.pn(
			"étais",
			"étais",
			"était",
			"étions",
			"étiez",
			"étaient"
		)
	end

	# @return [String]
	def aura
		self.pn(
			"aurai",
			"auras",
			"aura",
			"aurons",
			"aurez",
			"auront"
		)
	end

	# @return [String]
	def sera
		self.pn(
			"serai",
			"seras",
			"sera",
			"serons",
			"serez",
			"seront"
		)
	end

	# @return [String]
	def aurait
		self.pn(
			"aurais",
			"aurais",
			"aurait",
			"aurions",
			"auriez",
			"auraient"
		)
	end

	# @return [String]
	def serait
		self.pn(
			"serais",
			"serais",
			"serait",
			"serions",
			"seriez",
			"seraient"
		)
	end

	# @return [String]
	def le
		self.gn("le", "la", "les", "les")
	end

	# @return [String]
	def un
		self.gn("un", "une", "des", "des")
	end

	# @param verbe [String]
	# @return [String]
	def se(verbe)
		if verbe.voyelle?
			self.pn(
				"m’",
				"t’",
				"s’",
				"nous ",
				"vous ",
				"s’"
			) + verbe
		else
			self.pn(
				"me ",
				"te ",
				"se ",
				"nous ",
				"vous ",
				"se "
			)
		end
	end

	require_relative "acteur_proxy"

	# @return [Acteur]
	def to_1e_personne
		_nombre = if respond_to?(:qte)
			qte > 1 ? :P : :S
		else
			nombre
		end
		self.personne == 1 ? self : ActeurProxy.new(
			self,
			personne: 1,
			nombre: _nombre
		)
	end

	# @return [Acteur]
	def to_2e_personne
		_nombre = if respond_to?(:qte)
			qte > 1 ? :P : :S
		else
			nombre
		end
		self.personne == 2 ? self : ActeurProxy.new(
			self,
			personne: 2,
			nombre: _nombre
		)
	end

	# @return [Acteur]
	def to_3e_personne
		self.personne == 3 ? self : ActeurProxy.new(self, personne: 3)
	end

end
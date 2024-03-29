require "rosace"
require_relative "info"
require_relative "acteur"
require_relative "../refinements"
require_relative "../inspectable"

class Action < Rosace::Entity

	using Refinements

	include Inspectable

	self.file = "regles/action.csv"

	# @!attribute [r] info
	#  @return [Info, nil] Information pour laquelle cette action est définie
	reference :info, :Info, :optional

	# @!attribute [r] coupable
	#  @return [:sujet, :objet, :""]
	enum :coupable, *Info::ROLES

	# @!attribute [r] victime
	#  @return [:sujet, :objet, :""]
	enum :victime, *Info::ROLES

	# @!attribute [r] genre
	#  @return [:M, :F] Genre de la forme {nominale} de l’action
	enum :genre, *Acteur::GENRES

	# @!attribute [r] nombre
	#  @return [:S, :P] Nombre de la forme {nominale} de l’action
	enum :nombre, *Acteur::NOMBRES

	attr_writer :sujet
	attr_writer :objet

	# Retournes tous les lieux présents dans l'action.
	# @return [Array<Lieu>] Lieux présents dans l'action
	def lieux
		lieux = []
		[@sujet, @objet].each do |acteur|
			lieux << acteur.origine if acteur.respond_to?(:origine) &&
					acteur.origine
			lieux << acteur.lieu if acteur.respond_to?(:lieu) && acteur.lieu
			if acteur.is_a?(Lieu)
				lieux << acteur
			end
		end
		lieux.uniq
	end

	# @return [Acteur, nil] Acteur objet de cette action
	def objet
		@objet ||= (info ? info.objet : nil) || context.variable(:$info).acteur
		@objet.to_personne(personne_objet)
	end

	# @return [Acteur] Acteur sujet de cette action
	def sujet
		@sujet ||= (info ? info.sujet : nil) || context.variable(:$info).acteur
		@sujet.to_personne(personne_sujet)
	end

	def init
		self.temps = :passe
		@commun = false
		self.personne_sujet = nil
		self.personne_objet = nil
	end

	# @param args [Array<String>]
	# @return [Boolean]
	def pick?(*args)
		args.any? { |role| send(role) == :sujet } &&
				args.all? { |role| roles.include?(role.strip.to_sym) }
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @param coupable [Acteur, nil] Coupable de l'action. À éviter d'utiliser
	#  avec +sujet+ ou +objet+.
	# @param victime [Acteur, nil] victime de l'action. À éviter d'utiliser avec
	#  +sujet+ ou +objet+.
	# @param forme [:verbale, :nominale] Forme verbale ou nominale
	# @param temps [:simple, :passe, :infinitif, :infinitif_passe]
	# @param mettre_sujet [Boolean]
	# @param sujet_explicite [Boolean] Vrai si le sujet doit être écrit
	#  explicitement
	# @param verbe_obligatoire [Boolean] Faux pour omettre le verbe être
	# @param personne_sujet [1, 2, 3, nil] Personne du sujet
	# @param personne_objet [1, 2, 3, nil] Personne de l'objet
	# @param personne_coupable [1, 2, 3, nil] Personne du coupable
	# @param personne_victime [1, 2, 3, nil] Personne de la victime
	# @param adverbe_neg [String, nil] Adverbe de négation
	# @return [String, Acteur] String pour la forme verbale ou nominale dans
	#  sujet, Acteur pour la forme nominale avec sujet
	def value(sujet: nil,
			  objet: nil,
			  coupable: nil,
			  victime: nil,
			  forme: :verbale,
			  temps: :passe,
			  mettre_sujet: true,
			  sujet_explicite: false,
			  verbe_obligatoire: true,
			  personne_sujet: nil,
			  personne_objet: nil,
			  personne_coupable: nil,
			  personne_victime: nil,
			  adverbe_neg: nil)
		old_sujet = @sujet
		old_objet = @objet
		old_temps = self.temps
		old_mettre_sujet = self.mettre_sujet
		# @type [Acteur, nil]
		@sujet = sujet || old_sujet
		# @type [Acteur, nil]
		@objet = objet || old_objet
		self.coupable = coupable
		self.victime = victime
		self.personne_sujet = personne_sujet
		self.personne_objet = personne_objet
		self.personne_coupable = personne_coupable
		self.personne_victime = personne_victime
		self.temps = temps
		self.mettre_sujet = mettre_sujet
		@adverbe_neg = adverbe_neg
		pattern = /\A(est|sont) /
		out = if forme == :verbale
			if [:infinitif_passe, :infinitif].include?(self.temps) ||
				!mettre_sujet
				unless plain_value(:sujet_perso).empty?
					raise Rosace::EvaluationException,
							"Sujet perso pour Action[#{id}]"
				end
				verbale
			else
				sp = sujet_perso
				if !sp.empty?
					sp + " " + (verbe_obligatoire ?
							verbale :
							verbale.gsub(pattern, ""))
				elsif sujet_explicite && self.sujet.personne == 3
					self.sujet.sujet_explicite + " " + (verbe_obligatoire ?
							verbale :
							verbale.gsub(pattern, ""))
				else
					self.sujet.sujet(verbe_obligatoire ?
							verbale :
							verbale.gsub(pattern, ""))
				end
			end
		else
			nominale
		end
		@sujet = old_sujet || @sujet
		@objet = old_objet || @objet
		self.personne_sujet = nil
		self.personne_objet = nil
		self.temps = old_temps
		self.mettre_sujet = old_mettre_sujet
		@adverbe_neg = nil
		if forme == :nominale && mettre_sujet == true
			Acteur.new(nom: out, genre: genre, nombre: nombre)
		else
			out
		end
	end

	# @return [Integer] Poids de l'action dans les choix aléatoires
	def weight
		info = context.variable(:$info)
		(info && info.contient?(self)) ? 1 : super
	end

	# Appelle {#value} avec les arguments convertis dans le type attendu.
	# @param args [Array<String>] arguments sous la forme "clef:valeur"
	# @return [String, Acteur] Retour de {#value}
	def val(*args)
		kwargs = {}
		args.each do |arg|
			match = /\A\s*(?<clef>\w+)\s*:(?<valeur>.*)\z/.match(arg)
			if match.nil?
				raise Rosace::EvaluationException,
						"Action[#{id}]: Argument #{arg} mal formé"
			end
			valeur = match[:valeur].strip
			clef = match[:clef]
			case clef
			when "sujet"
				kwargs[:sujet] = context.variable(valeur)
			when "objet"
				kwargs[:objet] = context.variable(valeur)
			when "temps"
				kwargs[:temps] = valeur.to_sym
			when "mettre_sujet"
				kwargs[:mettre_sujet] = valeur != "false"
			when "coupable"
				kwargs[:coupable] = context.variable(valeur)
			when "victime"
				kwargs[:victime] = context.variable(valeur)
			when "forme"
				kwargs[:forme] = valeur.to_sym
			when "personne_sujet"
				kwargs[:personne_sujet] = valeur.to_i
			when "personne_objet"
				kwargs[:personne_objet] = valeur.to_i
			when "personne_coupable"
				kwargs[:personne_coupable] = valeur.to_i
			when "personne_victime"
				kwargs[:personne_victime] = valeur.to_i
			when "adverbe_neg"
				kwargs[:adverbe_neg] = valeur
			else
				raise Rosace::EvaluationException,
						"Action[#{id}]: Paramètre #{clef} inconnu"
			end
		end
		value(**kwargs)
	end

	# Conjugue le verbe selon ses différentes formes données.
	# @param auxiliaire ["être", "avoir"] Auxiliaire à utiliser
	# @param participe [String] Participe passé (accordé avec le sujet pour 
	#  l'auxiliaire +"être"+)
	# @param infinitif [String] Infinitif du verbe
	# @param s1 [String, nil] Première personne du singulier d'un temps simple
	#  (souvent présent ou futur)
	# @param s2 [String, nil] Deuxième personne du singulier
	# @param s3 [String, nil] Troisième personne du singulier
	# @param p1 [String, nil] Première personne du pluriel
	# @param p2 [String, nil] Deuxième personne du pluriel
	# @param p3 [String, nil] Troisième personne du pluriel
	# @param adverbe [String, nil] Adverbe
	# @return [String] Verbe conjugué selon le temps de l'action
	def verbe(auxiliaire,
			  participe,
			  infinitif,
			  s1 = nil,
			  s2 = nil,
			  s3 = nil,
			  p1 = nil,
			  p2 = nil,
			  p3 = nil,
			  adverbe = nil)
		unless ["être", "avoir"].include?(auxiliaire)
			raise Rosace::EvaluationException,
					"Action[#{id}]: #{auxiliaire} n'est pas un auxiliaire"
		end
		neg = adverbe_neg
		passe = if auxiliaire == "avoir"
			sujet.a + " " + (neg ? neg + " " : "") +
					(adverbe ? adverbe + " " : "") + participe
		else
			sujet.est + " " + (neg ? neg + " " : "") +
					(adverbe ? adverbe + " " : "") + participe
		end
		infinitif_passe = "#{auxiliaire} #{participe}" +
				(neg ? " " + neg : "") + (adverbe ?	" " + adverbe :	"")
		simple = sujet.pn(
			s1 || passe,
			s2 || passe,
			s3 || passe,
			p1 || passe,
			p2 || passe,
			p3 || passe
		) + (neg ? " " + neg : "") + (adverbe ? " " + adverbe : "")
		out = case temps
		when :passe
			passe
		when :infinitif
			(neg ? neg + " " : "") + infinitif + (adverbe ? " " + adverbe : "")
		when :infinitif_passe
			infinitif_passe
		else
			simple
		end
		neg ? (out.voyelle? ? "n’" + out : "ne " + out) : out
	end

	# Conjugue le verbe selon ses différentes formes données, avec l'auxiliaire
	#  *avoir* pour les temps composés.
	# @param participe [String] Participe passé
	# @param infinitif [String] Infinitif du verbe
	# @param s1 [String, nil] Première personne du singulier d'un temps simple
	#  (souvent présent ou futur)
	# @param s2 [String, nil] Deuxième personne du singulier
	# @param s3 [String, nil] Troisième personne du singulier
	# @param p1 [String, nil] Première personne du pluriel
	# @param p2 [String, nil] Deuxième personne du pluriel
	# @param p3 [String, nil] Troisième personne du pluriel
	# @param adverbe [String, nil] Adverbe
	# @return [String] Verbe conjugué selon le temps de l'action
	def a(participe,
		  infinitif,
		  s1 = nil,
		  s2 = nil,
		  s3 = nil,
		  p1 = nil,
		  p2 = nil,
		  p3 = nil,
		  adverbe = nil)
		verbe("avoir", participe, infinitif, s1, s2, s3, p1, p2, p3, adverbe)
	end

	# Conjugue le verbe selon ses différentes formes données, avec l'auxiliaire
	#  *être* pour les temps composés.
	# @param participe [String] Participe passé accordé avec le sujet
	# @param infinitif [String, nil] Infinitif du verbe
	# @param s1 [String, nil] Première personne du singulier d'un temps simple
	#  (souvent présent ou futur)
	# @param s2 [String, nil] Deuxième personne du singulier
	# @param s3 [String, nil] Troisième personne du singulier
	# @param p1 [String, nil] Première personne du pluriel
	# @param p2 [String, nil] Deuxième personne du pluriel
	# @param p3 [String, nil] Troisième personne du pluriel
	# @return [String] Verbe conjugué selon le temps de l'action
	def est(participe,
		  infinitif = nil,
		  s1 = nil,
		  s2 = nil,
		  s3 = nil,
		  p1 = nil,
		  p2 = nil,
		  p3 = nil)
		verbe("être", participe, infinitif || "être #{participe}", s1, s2, s3,
				p1, p2, p3)
	end

	# @return [String] Verbe *avoir* conjugué selon le temps de l'action (au
	#  présent pour le temps simple)
	def avoir
		a("eu", "avoir", "ai", "as", "a", "avons", "avez", "ont")
	end

	# @return [String] Verbe *être* conjugué selon le temps de l'action (au
	#  présent pour le temps simple)
	def etre
		a("été", "être", "suis", "es", "est", "sommes", "êtes", "sont")
	end

	# Partie de la forme {#nominale} contenant une alusion au sujet.
	# @param si_sujet [String] partie contenant le sujet
	# @param sinon [String] partie à retourner dans le cas contraire
	# @return [String] Partie contenant le sujet si {#mettre_sujet} est vrai
	def s(si_sujet, sinon = "")
		mettre_sujet ? si_sujet : sinon
	end

	# Retourne la proposition et le {sujet} en complément, ou non.
	# @param article [String] article du sujet de la proposition
	# @param nom [String] sujet de la proposition
	# @return la propositon avec ou non le {sujet} en complément
	def s_comp(article, nom)
		s(sujet.comp(article + nom), nom)
	end

	# @return [String, nil] Adverbe de négation
	def adverbe_neg
		if @adverbe_neg
			@adverbe_neg
		else
			s = super
			s.empty? ? nil : s
		end
	end

	# Retourne un motif d'accusation sous la forme "pour [forme infinitive ou
	# nominale]".
	# @param forcer_nominale [Boolean] Obliger la forme nominale
	# @return [String] motif d'accusation
	def pour_motif(forcer_nominale: false)
		args = {}
		args[:forme] = forcer_nominale ?
				:nominale :
				[:verbale, :nominale][rand(2)]
		args[:temps] = :infinitif_passe
		unless info.coupable.empty?
			args[:coupable] = info.coupable == :sujet ? sujet : objet
		end
		unless info.victime.empty?
			args[:victime] = info.victime == :sujet ? sujet : objet
		end
		args[:mettre_sujet] = false
		out = info.motif.value(**args)
		"pour " + (out.is_a?(Acteur) ? out.nom : out)
	end

	# Retourne un motif d'accusation sous la forme "pour [forme nominale]".
	# @return [String] motif d'accusation
	def pour_motif_nominal
		pour_motif(forcer_nominale: true)
	end

	# Retourne un motif d'accusation sous la forme "dans le cadre de
	# [motif]".
	# @return [String] motif d'accusation
	def dans_le_cadre_de_motif
		args = {}
		args[:forme] = :nominale
		unless info.coupable.empty?
			args[:coupable] = info.coupable == :sujet ? sujet : objet
		end
		unless info.victime.empty?
			args[:victime] = info.victime == :sujet ? sujet : objet
		end
		args[:mettre_sujet] = true
		out = info.motif.value(**args)
		"dans " + out.comp("le cadre")
	end

	# Retourne un motif d'accusation sous la forme "parce que [motif]"
	# @return [String] motif d'accusation
	def parce_que_motif
		args = {}
		args[:forme] = :verbale
		args[:temps] = :passe
		unless info.coupable.empty?
			args[:coupable] = info.coupable == :sujet ? sujet : objet
		end
		unless info.victime.empty?
			args[:victime] = info.victime == :sujet ? sujet : objet
		end
		args[:mettre_sujet] = true
		out = info.motif.value(**args)
		"parce qu#{out.voyelle? ? "’" : "e "}#{out}"
	end

	# @return [List<:coupable, :victime>] Liste des rôles définis pour cette
	#  action.
	def roles
		roles = []
		roles << :coupable if !coupable.empty?
		roles << :victime if !victime.empty?
		roles
	end

	# Calcule la distance avec la chaîne donnée.
	# @param chaine [String] Chaîne à comparer
	# @return [Integer] Nombre de différences entre les deux chaînes
	def distance(chaine)
		plain_value(:nominale).levenshtein(chaine)
	end

	# Exécute les macros définis dans l'attribut +commun+ avant d'accéder aux
	# informations de l'action.
	# @return [void]
	def commun
		unless @commun
			super
			info.commun if info
			@commun = true
		end
		self
	end

	# @return [String] Forme verbale de l'action
	def verbale
		commun
		super
	end

	# @return [String] Forme nominale de l'action
	def nominale
		commun
		super
	end

	# @return [String] Sujet personnalisé de l'action
	def sujet_perso
		commun
		super
	end

	# @return [String] Partie comprenant le motif
	def part_motif
		commun
		super
	end

	private

	# @return [:passe, :infinitif, :infinitif_passe, :simple] Temps du verbe de
	#  l'action :
	#  - +:passe+ pour le passé composé
	#  - +:infinitif+ pour l'infinitif présent
	#  - +:infinitif_passe+ pour l'infinitif passé
	#  - +:simple+ pour le temps simple de l'action, généralement le présent ou
	#    le futur
	attr_reader :temps

	# @return [Boolean] Vrai s'il faut retourner explicitement le sujet dans les
	#  formes nominale ou verbale.
	attr_accessor :mettre_sujet

	# @return [1, 2, 3, nil] Personne grammaticale du sujet (+nil+ pour
	#  inchangé)
	attr_accessor :personne_sujet

	# @return [1, 2, 3, nil] Personne grammaticale de l'objet (+nil+ pour
	#  inchangé)
	attr_accessor :personne_objet

	def temps=(temps)
		@temps = temps || self.temps
	end

	# Définit le coupable de l'action.
	# @param coupable [Acteur] Coupable de l'action
	# @return [void]
	def coupable=(coupable)
		case self.coupable
		when :sujet
			self.sujet = coupable || self.sujet
		when :objet
			self.objet = coupable || self.objet
		end
	end

	# Définit la victime de l'action.
	# @param victime [Acteur] Victime de l'action
	# @return [void]
	def victime=(victime)
		case self.victime
		when :sujet
			self.sujet = victime || self.sujet
		when :objet
			self.objet = victime || self.objet
		end
	end

	# Définit la personne du coupable
	# @param personne [1, 2, 3, nil] personne du coupable
	# @return [1, 2, 3, nil]
	def personne_coupable=(personne)
		case self.coupable
		when :sujet
			self.personne_sujet = personne || personne_sujet
		when :objet
			self.personne_objet = personne || personne_objet
		end
	end

	# Définit la personne de la victime
	# @param personne [1, 2, 3, nil] personne de la victime
	# @return [1, 2, 3, nil]
	def personne_victime=(personne)
		case self.victime
		when :sujet
			self.personne_sujet = personne || personne_sujet
		when :objet
			self.personne_objet = personne || personne_objet
		end
	end

end
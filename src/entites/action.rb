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
			if acteur.is_a?(Pers) || acteur.is_a?(Entreprise)
				lieux << acteur.origine if acteur.origine
			elsif acteur.is_a?(Lieu)
				lieux << acteur
			end
		end
		lieux.uniq
	end

	# @return [Acteur, nil] Acteur objet de cette action
	def objet
		# @type [Info]
		@objet || (info ? info.objet : nil)
	end

	# @return [Acteur] Acteur sujet de cette action
	def sujet
		@sujet || (info ? info.sujet : nil)
	end

	def init
		self.temps = :passe
		@commun = false
	end

	# @param args [Array<String>]
	# @return [Boolean]
	def pick?(*args)
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
	# @return [String, Acteur] String pour la forme verbale ou nominale dans
	#  sujet, Acteur pour la forme nominale avec sujet
	def value(sujet: nil,
			  objet: nil,
			  coupable: nil,
			  victime: nil,
			  forme: :verbale,
			  temps: :passe,
			  mettre_sujet: true,
			  sujet_explicite: false)
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
		self.temps = temps
		self.mettre_sujet = mettre_sujet
		out = if forme == :verbale
			if [:infinitif_passe, :infinitif].include?(self.temps) ||
				!mettre_sujet
				verbale
			else
				sp = sujet_perso
				if !sp.empty?
					sp + " " + verbale
				elsif sujet_explicite
					self.sujet.sujet_explicite + " " + verbale
				else
					self.sujet.sujet(verbale)
				end
			end
		else
			nominale
		end
		@sujet = old_sujet
		@objet = old_objet
		self.temps = old_temps
		self.mettre_sujet = old_mettre_sujet
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
	# @return [String] Verbe conjugué selon le temps de l'action
	def verbe(auxiliaire,
			  participe,
			  infinitif,
			  s1 = nil,
			  s2 = nil,
			  s3 = nil,
			  p1 = nil,
			  p2 = nil,
			  p3 = nil)
		unless ["être", "avoir"].include?(auxiliaire)
			raise Rosace::EvaluationException,
					"Action[#{id}]: #{auxiliaire} n'est pas un auxiliaire"
		end
		passe = (auxiliaire == "avoir" ? sujet.a : sujet.est) + " " + participe
		infinitif_passe = "#{auxiliaire} #{participe}"
		simple = sujet.pn(
			s1 || passe,
			s2 || passe,
			s3 || passe,
			p1 || passe,
			p2 || passe,
			p3 || passe
		)
		case temps
		when :passe
			passe
		when :infinitif
			infinitif
		when :infinitif_passe
			infinitif_passe
		else
			simple
		end
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
	# @return [String] Verbe conjugué selon le temps de l'action
	def a(participe,
		  infinitif,
		  s1 = nil,
		  s2 = nil,
		  s3 = nil,
		  p1 = nil,
		  p2 = nil,
		  p3 = nil)
		verbe("avoir", participe, infinitif, s1, s2, s3, p1, p2, p3)
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

	# Retourne un motif d'accusation sous la forme "pour [forme infinitive ou
	# nominale]".
	# @param forcer_nominale [Boolean] Obliger la forme nominale
	# @return [String] motif d'accusation
	def pour_motif(forcer_nominale: false)
		# @type [Action]
		motif = info.motif ||= context.pick_entity(:Action,
				*info.roles.map { |role| role.id2name })
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
		out = motif.value(**args)
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
		# @type [Action]
		motif = info.motif ||= context.pick_entity(:Action,
				*info.roles.map { |role| role.id2name })
		args = {}
		args[:forme] = :nominale
		args[:temps] = :infinitif_passe
		unless info.coupable.empty?
			args[:coupable] = info.coupable == :sujet ? sujet : objet
		end
		unless info.victime.empty?
			args[:victime] = info.victime == :sujet ? sujet : objet
		end
		args[:mettre_sujet] = true
		out = motif.value(**args)
		"dans " + out.comp("le cadre")
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

end
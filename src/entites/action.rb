require "rosace"
require_relative "info"
require_relative "../refinements"

class Action < Rosace::Entity

	using Refinements

	self.file = "regles/action.csv"

	# @!attribute [r] verbale
	#  @return [String]
	# @!attribute [r] nominale
	#  @return [String]
	# @!attribute [r] sujet_perso
	#  @return [String]

	reference :info, :Info, :optional

	# @!attribute [r] coupable
	#  @return [:sujet, :objet, :""]
	enum :coupable, *Info::ROLES

	# @!attribute [r] victime
	#  @return [:sujet, :objet, :""]
	enum :victime, *Info::ROLES

	# @!attribute [r] denonciateur
	#  @return [:sujet, :objet, :""]
	enum :denonciateur, *Info::ROLES

	def init
		self.temps = :passe
	end

	# @param args [Array<String>]
	# @return [Boolean]
	def pick?(*args)
		args.any? { |role| !role.empty? && send(role) == :sujet }
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @param temps [:simple, :passe, :infinitif, :infinitif_passe]
	# @param mettre_sujet [Boolean]
	# @return [String]
	def value(sujet: nil, objet: nil, temps: :passe, mettre_sujet: true)
		old_sujet = @sujet
		old_objet = @objet
		old_temps = self.temps
		# @type [Acteur, nil]
		@sujet = sujet || old_sujet
		# @type [Acteur, nil]
		@objet = objet || old_objet
		self.temps = temps || self.temps
		out = if [:infinitif_passe, :infinitif].include?(self.temps) ||
			!mettre_sujet
			verbale
		else
			sp = sujet_perso
			unless sp.empty?
				sp + " " + verbale
			else
				self.sujet.sujet(verbale)
			end
		end
		@sujet = old_sujet
		@objet = old_objet
		self.temps = old_temps
		out
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

	# @param nom_var [String]
	# @return [String]
	def avec_sujet(nom_var)
		value(sujet: context.variable(nom_var))
	end

	# @param nom_var [String]
	# @param var_info_accu [String, nil]
	# @return [String]
	def nominale_avec_sujet(nom_var, id_info_accu = nil)
		old_sujet = @sujet
		old_info = @info_accu
		@sujet = context.variable(nom_var)
		@info_accu = id_info_accu ?
				context.entity(:Info, id_info_accu.to_i) :
				old_info
		out = nominale
		@sujet = old_sujet
		@info_accu = old_info
		out
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @return [String]
	def pour(sujet: nil, objet: nil)
		old_sujet = @sujet
		old_objet = @objet
		@sujet = sujet || old_sujet
		@objet = objet || old_objet
		out = "pour " + infinitif_ou_nom
		@sujet = old_sujet
		@objet = old_objet
		out
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @return [String]
	def de(sujet: nil, objet: nil)
		old_sujet = @sujet
		old_objet = @objet
		@sujet = sujet || old_sujet
		@objet = objet || old_objet
		out = infinitif_ou_nom
		@sujet = old_sujet
		@objet = old_objet
		out.voyelle? ? "d’" + out : "de " + out
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @return [String]
	# @raise [Rosace::EvaluationException]
	def qui(sujet: nil, objet: nil)
		unless sujet_perso.empty?
			raise Rosace::EvaluationException,
				"Action[#{id}]: l’action a un sujet personnalisé"
		end
		"qui " + value(
			sujet: sujet,
			objet: objet,
			temps: :passe,
			mettre_sujet: false
		)
	end

	# @param var_sujet [String]
	# @param id_info_accu [String, nil]
	# @return [String]
	def infinitif_passe_seul(var_sujet, id_info_accu = nil)
		unless sujet_perso.empty?
			raise Rosace::EvaluationException,
				"Action[#{id}]: l’action a un sujet personnalisé"
		end
		old_info = @info_accu
		@info_accu = id_info_accu ?
				context.entity(:Info, id_info_accu.to_i) :
				old_info
		out = value(sujet: context.variable(var_sujet), temps: :infinitif_passe,
				mettre_sujet: false)
		@info_accu = old_info
		out
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @return [String]
	def car(sujet: nil, objet: nil)
		"car " + value(sujet: sujet, objet: objet, temps: :passe)
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @return [String]
	def parce_que(sujet: nil, objet: nil)
		out = value(sujet: sujet, objet: objet, temps: :passe)
		(out.voyelle? ? "parce qu’" : "parce que ") + out
	end

	# @param info [Info, nil]
	# @return [String]
	def accusation(info: nil)
		case rand(3)
		when 0
			accusation_pour(info: info)
		when 1
			accusation_car(info: info)
		else
			accusation_parce_que(info: info)
		end
	end

	# @param info [Info, nil]
	# @return [String]
	def accusation_de(info: nil)
		old_info = @info_accu
		# @type [Info, nil]
		@info_accu = info || old_info
		out = de
		@info_accu = old_info
		out
	end

	# @param info [Info, nil]
	# @return [String]
	def accusation_pour(info: nil)
		old_info = @info_accu
		@info_accu = info || old_info
		out = pour
		@info_accu = old_info
		out
	end

	# @param info [Info, nil]
	# @return [String]
	def accusation_car(info: nil)
		old_info = @info_accu
		@info_accu = info || old_info
		out = car
		@info_accu = old_info
		out
	end

	# @param info [Info, nil]
	# @return [String]
	def accusation_parce_que(info: nil)
		old_info = @info_accu
		@info_accu = info || old_info
		out = parce_que
		@info_accu = old_info
		out
	end

	# @param info [Info, nil]
	# @return [String]
	def accusation_qui(info: nil)
		old_info = @info_accu
		@info_accu = info || old_info
		out = qui
		@info_accu = old_info
		out
	end

	# @return [Acteur, nil]
	def sujet
		if @sujet
			@sujet
		elsif @info_accu
			get_accusation_sujet(@info_accu)
		elsif info
			info.sujet
		else
			nil
		end
	end

	# @return [Acteur, nil]
	def objet
		if @objet
			@objet
		elsif @info_accu
			get_accusation_objet(@info_accu)
		elsif info
			info.objet
		else
			nil
		end
	end

	# @param acteur [Acteur]
	# @return [Acteur]
	def objet=(acteur)
		if info(static: true)
			info(static: true).objet = acteur
		else
			@objet = acteur
		end
	end

	# @param static [Boolean]
	# @return [Info, nil]
	def info(static: false)
		if static
			super()
		else
			@info_accu || super()
		end
	end

	private

	# @return [String]
	def infinitif_ou_nom
		rand(2) == 1 ?
			value(temps: :infinitif_passe) :
			nominale.gsub(/\A(un |une |des |le |la |les |l’)/, "")
	end

	# @param info [Info]
	# @return [Acteur, nil]
	def get_accusation_sujet(info)
		if victime == :sujet
			info.get_victime(action: self)
		elsif coupable == :sujet
			info.get_coupable(action: self)
		elsif denonciateur == :sujet
			info.get_denonciateur(action: self)
		else
			nil
		end
	end

	# @param info [Info]
	# @return [Acteur, nil]
	def get_accusation_objet(info)
		if victime == :objet
			info.get_victime(action: self)
		elsif coupable == :objet
			info.get_coupable(action: self)
		elsif denonciateur == :objet
			info.get_denonciateur(action: self)
		else
			nil
		end || info.acteur
	end

	private

	# @return [:passe, :infinitif, :infinitif_passe, :simple] Temps du verbe de
	#  l'action :
	#  - +:passe+ pour le passé composé
	#  - +:infinitif+ pour l'infinitif présent
	#  - +:infinitif_passe+ pour l'infinitif passé
	#  - +:simple+ pour le temps simple de l'action, généralement le présent ou
	#    le futur
	attr_accessor :temps

end
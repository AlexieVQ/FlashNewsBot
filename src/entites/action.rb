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
		# @type [:present, :passe, :infinitif_present, :infinitif_passe]
		@temps = :passe
	end

	# @param args [Array<String>]
	# @return [Boolean]
	def pick?(*args)
		args.any? { |role| !role.empty? && send(role) == :sujet }
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @param temps [:present, :passe, :infinitif_present, :infinitif_passe]
	# @param sujet? [Boolean]
	# @return [String]
	def value(sujet: nil, objet: nil, temps: :passe, mettre_sujet: true)
		old_sujet = @sujet
		old_objet = @objet
		old_temps = @temps
		# @type [Acteur, nil]
		@sujet = sujet || old_sujet
		# @type [Acteur, nil]
		@objet = objet || old_objet
		@temps = temps || @temps
		out = if [:infinitif_passe, :infinitif_present].include?(@temps) ||
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
		@temps = old_temps
		out
	end

	# @param present [String]
	# @param passe [String]
	# @param infinitif_present [String]
	# @param infinitif_passe [String]
	# @return [String]
	def verbe(present, passe, infinitif_present, infinitif_passe)
		case @temps
		when :present
			present
		when :passe
			passe
		when :infinitif_present
			infinitif_present
		when :infinitif_passe
			infinitif_passe
		else
			passe
		end
	end

	# @return [String]
	def etre
		verbe(sujet.est, sujet.est, "être", "être")
	end

	# @return [String]
	def avoir_ete
		verbe(sujet.est, "#{sujet.a} été", "être", "avoir été")
	end

	# @return [String]
	def avoir
		verbe(sujet.a, sujet.a, "avoir", "avoir")
	end

	# @return [String]
	def avoir_eu
		verbe(sujet.a, "#{sujet.a} eu", "avoir", "avoir eu")
	end

	# @param s1 [String]
	# @param s2 [String]
	# @param s3 [String]
	# @param p1 [String]
	# @param p2 [String]
	# @param p3 [String]
	# @param infinitif [String]
	# @param participe [String]
	# @return [String]
	def a(s1, s2, s3, p1, p2, p3, infinitif, participe)
		verbe(
			sujet.pn(s1, s2, s3, p1, p2, p3),
			"#{sujet.a} #{participe}",
			infinitif,
			"avoir #{participe}"
		)
	end


	# @param s1 [String]
	# @param s2 [String]
	# @param s3 [String]
	# @param p1 [String]
	# @param p2 [String]
	# @param p3 [String]
	# @param infinitif [String]
	# @param participe [String]
	# @return [String]
	def est(s1, s2, s3, p1, p2, p3, infinitif, participe)
		verbe(
			sujet.pn(s1, s2, s3, p1, p2, p3),
			"#{sujet.est} #{participe}",
			infinitif,
			"être #{participe}"
		)
	end

	# @param nom_var [String]
	# @return [String]
	def avec_sujet(nom_var)
		value(sujet: context.variable(nom_var))
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

end
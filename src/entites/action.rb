require "rosace"
require_relative "info"
require_relative "../refinements"

class Action < Rosace::Entity

	using Refinements

	self.file = "regles/action.csv"

	# @!attribute [r] verbe
	#  @return [String]
	# @!attribute [r] infinitif
	#  @return [String]
	# @!attribute [r] complement
	#  @return [String]
	# @!attribute [r] forme_nom
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

	# @param args [Array<String>]
	# @return [Boolean]
	def pick?(*args)
		args.any? { |role| !role.empty? && send(role) == :sujet }
	end

	# @return [Boolean]
	def verbe_obligatoire
		super.to_i == 1
	end

	# @return [Boolean]
	def verbe_contient_sujet
		super.to_i == 1
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @param force_verbe [Boolean]
	# @return [String]
	def value(sujet: nil, objet: nil, force_verbe: true)
		old_sujet = @sujet
		old_objet = @objet
		# @type [Acteur, nil]
		@sujet = sujet || old_sujet
		# @type [Acteur, nil]
		@objet = objet || old_objet
		out = if verbe_contient_sujet
			verbe
		elsif verbe_obligatoire || force_verbe
			self.sujet.sujet(verbe)
		else
			self.sujet.sujet_explicite
		end
		c = complement
		unless c.empty?
			out += " " + c
		end
		@sujet = old_sujet
		@objet = old_objet
		out
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
		if verbe_contient_sujet
			raise Rosace::EvaluationException,
				"Action[#{id}]: le verbe contient le sujet"
		end
		old_sujet = @sujet
		old_objet = @objet
		@sujet = sujet || old_sujet
		@objet = objet || old_objet
		out = "qui " + verbe + " " + complement
		@sujet = old_sujet
		@objet = old_objet
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @return [String]
	def car(sujet: nil, objet: nil)
		"car " + value(sujet: sujet, objet: objet)
	end

	# @param sujet [Acteur, nil]
	# @param objet [Acteur, nil]
	# @return [String]
	def parce_que(sujet: nil, objet: nil)
		out = value(sujet: sujet, objet: objet)
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
			infinitif + " " + complement :
			forme_nom.gsub(/\A(un |une |des |le |la |les |l’)/, "")
	end

	# @param info [Info]
	# @return [Acteur, nil]
	def get_accusation_sujet(info)
		if victime == :sujet
			info.get_victime
		elsif coupable == :sujet
			info.get_coupable
		elsif denonciateur == :sujet
			info.get_denonciateur
		else
			nil
		end
	end

	# @param info [Info]
	# @return [Acteur, nil]
	def get_accusation_objet(info)
		if victime == :objet
			info.get_victime
		elsif coupable == :objet
			info.get_coupable
		elsif denonciateur == :objet
			info.get_denonciateur
		else
			nil
		end || info.acteur
	end

end
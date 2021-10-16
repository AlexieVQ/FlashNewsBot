require "rosace"
require_relative "info"

class Decla < Rosace::Entity
	
	self.file = "regles/decla.csv"

	ROLES = Info::ROLES + [:tierce, :coupable, :victime, :denonciateur]
	
	# @!attribute [r] ref_info
	#  @return [Info, nil]
	reference :ref_info, :Info, :optional

	enum :sujet, *ROLES.reject { |role| role.empty? }

	enum :objet, *ROLES

	# @!attribute [r] pers
	#  @return [Pers, nil]
	reference :pers, :Pers, :optional

	# @param info [Info, nil]
	# @return [String]
	def value(info: nil)
		old_info = @info
		# @type [Info, nil]
		@info = info || old_info
		out = super()
		@info = old_info
		out
	end

	# @param args [Array<String>]
	# @return [Boolean]
	def pick?(*args)
		roles = [:coupable, :victime, :denonciateur]
		if args.all? { |arg| arg.empty? }
			ref_info == nil &&
				!roles.include?(sujet(sym: true)) &&
				!roles.include?(objet(sym: true))
		else
			args.any? { |role| sujet(sym: true) == role.to_sym }
		end
	end

	# @return [Info, nil]
	def info
		@info || ref_info || context.variable(:info)
	end

	# @param sym [Boolean]
	# @return [Symbol, Acteur, nil]
	def sujet(sym: false)
		if sym
			super()
		else
			(@sujet || pers || case super()
			when :sujet
				info.sujet
			when :objet
				info.objet
			when :coupable
				info.get_coupable
			when :victime
				info.get_victime
			when :denonciateur
				info.get_denonciateur
			else
				@sujet = info.acteur
			end).to_1e_personne
		end
	end

	# @param sym [Boolean]
	# @return [Symbol, Acteur, nil]
	def objet(sym: false)
		if sym
			super()
		else
			@objet || case super()
			when :sujet
				info.sujet
			when :objet
				info.objet
			when :coupable
				info.get_coupable
			when :victime
				info.get_victime
			when :denonciateur
				info.get_denonciateur
			else
				@objet = info.acteur
			end
		end
	end
end
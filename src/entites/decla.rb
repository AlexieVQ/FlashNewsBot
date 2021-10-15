require "rosace"
require_relative "info"

class Decla < Rosace::Entity
	
	self.file = "regles/decla.csv"

	ROLES = Info::ROLES + [:tierce]
	
	reference :info, :Info, :optional

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

	# @return [Boolean]
	def pick?
		info == nil
	end

	# @return [Info, nil]
	def info
		@info || super || context.variable(:info)
	end

	# @return [Acteur, nil]
	def sujet
		(@sujet || pers || case super
		when :sujet
			info.sujet
		when :objet
			info.objet
		else
			@sujet = info.acteur
		end).to_1e_personne
	end

	# @return [Acteur, nil]
	def objet
		@objet || case super
		when :sujet
			info.sujet
		when :objet
			info.objet
		else
			@objet = info.acteur
		end
	end
end
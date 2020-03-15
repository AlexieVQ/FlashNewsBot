##
# Compte sur lequel poster (superclasse pour CompteTwitter). Classe abstraite.

class Compte
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	private_class_method :new
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Identifiant du compte dans la base de données (Integer)
	attr_reader :id
	
	##
	# Nom d'utilisateur du compte, sans son domaine (String)
	attr_reader :username
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne un String de la forme
	# <tt><em>utilisateur</em>@<em>domaine</em></tt>.
	def to_s
		return "#{self.username}@#{self.domaine}"
	end
	
end

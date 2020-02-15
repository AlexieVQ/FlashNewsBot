##
# API du réseau social (superclasse pour TwitterApi). Classe abstraite.

class Api
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouvel accès à l'API pour le compte d'<tt>username</tt> donné. Si
	# le compte n'existe pas dans la base de données, il est créé et initialisé.
	#
	# *Attention* : la classe Api ne peut être instanciée.
	#
	# Paramètres :
	# [+username+]  Nom d'utilisateur (String)
	def initialize(username)
		auth(username)
	end
	
end

require_relative 'Bot.rb'
require_relative 'String.rb'

##
# Classe permettant de tester les tendances.

class TestTendances
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Lance l'exécution du programme de test.
	#
	# Paramètres :
	# [+username+]      Nom d'utilisateur du compte Twitter (String)
	def TestTendances.exec(username)
		Bot.init(false, username, 60)
		Bot.compte.tendances.each { |tendance| puts tendance }
		puts "Le Coronavirus est irresponsable et joue à Habbo après avoir voté".chercher(Bot.compte.tendances)
	end
	
end

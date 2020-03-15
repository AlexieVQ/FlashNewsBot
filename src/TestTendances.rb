#!/usr/bin/env ruby

require_relative 'Bot.rb'

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
	end
	
end

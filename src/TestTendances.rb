require_relative 'Bot.rb'
require_relative 'String.rb'
require_relative 'elements/Pers.rb'
require_relative 'elements/Info.rb'

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
		puts Bot.compte.tendances
		puts "## PERS ##"
		Pers.each { |pers|
			t = pers.chercher(Bot.compte.tendances)
			if(t.length > 0) then
				puts "#{pers.id} : #{t.join(", ")}"
			end
		}
		puts "## INFOS ##"
		Info.each { |info|
			t = info.chercher(Bot.compte.tendances)
			if(t.length > 0) then
				puts "#{info.id} : #{t.join(", ")}"
			end
		}
	end
	
end

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
	# [+password+]      Mot de passe de la base de données (String)
	def TestTendances.exec(username, password)
		Bot.init(false, username, 60, true, password)
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
		puts "## CLASSEMENT PERS ##"
		Pers.sort {
			|a, b| a.poids <=> b.poids
		}.reverse.each_with_index { |pers, i|
			puts "#{i + 1} : #{pers.id} (#{pers.poids})"
		}
		puts "## CLASSEMENT INFOS ##"
		Info.sort {
			|a, b| a.poids <=> b.poids
		}.reverse.each_with_index { |info, i|
			puts "#{i + 1} : #{info.id} (#{info.poids})"
		}
	end
	
end

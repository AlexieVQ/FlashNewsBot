#!/usr/bin/env ruby

require 'optparse'
require_relative 'src/Bot.rb'
require_relative 'src/TestTendances.rb'

intervalle = 60
hors_ligne = false
username = ""
tendances = false
debug = false
password = ""
taux = 0
opt_parser = OptionParser.new { |opts|
	opts.banner = "Utilisation : #{$PROGRAM_NAME} [options]"
	
	opts.on("-o", "--off-line",
	        "Génère des status, sans les poster sur un réseau social") {
		hors_ligne = true
    }
	
	opts.on("-t", "--tendances", "Analyse les tendances") {
		tendances = true
	}
	
	opts.on("-d", "--debug", "Mode débuggage") {
		debug = true
	}
	
	opts.on("-uUSERNAME", "--username=USERNAME",
	        "Nom d'utilisateur sur le réseau social") { |u|
		username = u
	}
	
	opts.on("-iDUREE", "--intervalle=DUREE",
	        "Intervalle (en min) entre deux posts (par défaut 60 min)") { |i|
		intervalle = i.to_f
	}
	
	opts.on("-pPASSWORD", "--password=PASSWORD",
			"Mot de passe de la base de donnée (mode en ligne uniquement)"
		   ) { |pw|
		password = pw
	}
                              
	opts.on("-rTAUX", "--reponses=TAUX",
            "Taux de mentions traitées (de 0 à 100 inclus, 0 par défaut)") { |t|
		taux = t.to_i
	}
	
	opts.on("-h", "--help", "Affiche l'aide") {
		puts opts
		exit
	}
	
}.parse!

if(!hors_ligne && username.empty?) then
	$stderr.puts("Vous devez préciser un nom d'utilisateur, ou utiliser -o " +
				 "(-h ou --help pour l'aide)")
	exit
end

if(tendances && username.empty?) then
	$stderr.puts("Vous devez préciser un nom d'utilisateur")
	exit
end

if(tendances) then
	TestTendances.exec(username, password)
else
	Bot.exec(hors_ligne, username, intervalle, debug, password, taux)
end

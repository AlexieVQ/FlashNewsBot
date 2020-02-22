#!/usr/bin/env ruby

require 'optparse'
require_relative 'src/Bot.rb'

intervalle = 60
hors_ligne = false
username = ""
opt_parser = OptionParser.new do |opts|
	opts.banner = "Utilisation : #{$PROGRAM_NAME} [options]"
	
	opts.on("-o", "--off-line",
	        "Génère des status, sans les poster sur un réseau social") do
		hors_ligne = true
	end
	
	opts.on("-uUSERNAME", "--username=USERNAME",
	        "Nom d'utilisateur sur le réseau social") do |u|
		username = u
	end
	
	opts.on("-iDUREE", "--intervalle=DUREE",
	        "Intervalle (en min) entre deux posts (par défaut 60 min)") do |i|
		intervalle = i.to_f
	end
	
	opts.on("-h", "--help", "Affiche l'aide") do
		puts opts
		exit
	end
	
end.parse!

if !hors_ligne && username == "" then
	puts "Vous devez préciser un nom d'utilisateur, ou utiliser -o (-h ou" +
			" --help pour l'aide)"
	exit
end

Bot.exec(hors_ligne, username, intervalle)

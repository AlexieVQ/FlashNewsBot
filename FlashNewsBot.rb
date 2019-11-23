#!/usr/bin/env ruby

require 'optparse'
require 'daemons'
require_relative 'classes/Status.rb'
require_relative 'classes/Bdd.rb'
require_relative 'classes/Api.rb'

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

$bdd = Bdd.new
appname = username == "" ? "FNBOffLine" : username
$dir = Dir.pwd

unless hors_ligne then
	api = Api.connecter(username)
	Daemons.daemonize({backtrace: true,
	                   app_name: appname,
	                   log_output: true})
	$bdd = Bdd.new
end

loop do

	status = Status.creer

	puts status
	unless hors_ligne then
		if status.texte.length <= api.limite then
			api.envoyer(status.texte)
		end
	end
	
	sleep(60 * intervalle)
	
end

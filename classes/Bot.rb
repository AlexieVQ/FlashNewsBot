require 'daemons'
require_relative 'Status.rb'
require_relative 'Bdd.rb'
require_relative 'CompteTwitter.rb'
require_relative 'elements/Info.rb'
require_relative 'elements/Pers.rb'
require_relative 'elements/Accroche.rb'
require_relative 'elements/DateInfo.rb'
require_relative 'elements/Lieu.rb'
require_relative 'elements/Localite.rb'
require_relative 'elements/Parti.rb'
require_relative 'elements/Media.rb'
require_relative 'elements/Circo.rb'
require_relative 'elements/Decla.rb'

##
# Classe contenant le programme principal du bot.

class Bot
	
	#######################
	# VARIABLES DE CLASSE #
	#######################
	
	# @@bdd		=> Base de données
	# @@dir		=> Chemin du dossier contenant FlashNewsBot.rb (String)
	# @@index	=> Index (Hash)
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Lance l'exécution du bot.
	#
	# Le bot est d'abord initialisé, puis il est démonisé. Si +offline+ est à
	# +false+, le bot se connecte sur le compte d'+username+ donné avant d'être
	# démonisé. S'il est à +true+, le programme n'est pas démonisé et les
	# résultats s'affichent sur la sortie standard.
	#
	# Paramètres :
	# [+offline+]       Indique si le bot doit être exécuté hors-ligne (+true+,
	#                   status générés écrits sur la sortie standard) ou en
	#                   ligne (+false+, status envoyés au compte Twitter donné)
	# [+username+]      Nom d'utilisateur du compte Twitter (String, ignoré si
	#                   +offline+ est à +true+)
	# [+intervalle+]    Intervalle, en minutes, entre chaque status (Integer ou
	#                   Float)
	def Bot.exec(offline, username, intervalle)
		@@bdd = Bdd.new
		@@intervalle = intervalle
		appname = username == "" ? "FNBOffline" : username
		@@dir = Dir.pwd
		
		unless(offline) then
			compte = CompteTwitter.connecter(username)
			Daemons.daemonize({backtrace: true,
							   app_name: appname,
							   log_output: true})
			@@bdd = Bdd.new
		end

		loop do
			
			status = Status.new

			puts "[#{Time.now}] #{status} " +
			     "(#{status.info.categories.join(", ")})"
			unless(offline) then
				if(status.texte.length <= compte.limite) then
					compte.envoyer(status)
				end
			end
			
			compte.update_statuses if(compte)
			
			sleep(60 * @@intervalle)
			
		end
	end
	
	##
	# Chemin du répertoire où se trouve l'exécutable <tt>FlashNewsBot.rb</tt>
	# (String).
	def Bot.dir
		return @@dir
	end
	
	##
	# Base de données (Bdd)
	def Bot.bdd
		return @@bdd
	end
	
	##
	# Intervalle (minutes) entre chaque status (Integer ou Float)
	def Bot.intervalle
		return @@intervalle
	end
	
	##
	# Index (Hash) faisant correspondre des identifiants utilisés dans les
	# expressions à leurs valeurs associées.
	#
	# Les éléments présent dans l'index sont des Expression, des instances ou
	# des classes héritant de Element. Ils doivent tous implémenter une méthode
	# +retourner+ prenant en paramètres +attribut+ (String) et +pamaretres+
	# (Array de String). Voir la documentation de String#evaluer pour plus de
	# détails.
	def Bot.index
		return @@index
	end
	
	##
	# (Ré)initialise l'index (voir Bot::index) en définissant les commandes
	# +rand+, +maj+, +cap+, +genre+, +gse+, +h+ (voir Expression) et les classes
	# d'éléments +accroche+ (voir Accroche), +pers+ (voir Pers), +date+ (voir
	# DateInfo), +lieu+ (voir Lieu), +localite+ (voir Localite), +parti+ (voir
	# Parti), +media+ (voir Media), +circo+ (voir Circo) et +decla+ (voir
	# Decla).
	def Bot.index_reset
		@@index = Hash.new
		
		@@index['rand'] = Expression.new(:rand)
		@@index['maj'] = Expression.new(:maj)
		@@index['cap'] = Expression.new(:cap)
		@@index['genre'] = Expression.new(:genre)
		@@index['gse'] = Expression.new(:gse)
		@@index['h'] = Expression.new(:h)
		@@index['randn'] = Expression.new(:randn)
		@@index['loc_principale'] = Expression.new(:loc_principale)
		@@index['accroche'] = Accroche
		@@index['pers'] = Pers
		@@index['date'] = DateInfo
		@@index['lieu'] = Lieu
		@@index['localite'] = Localite
		@@index['parti'] = Parti
		@@index['media'] = Media
		@@index['circo'] = Circo
		@@index['decla'] = Decla
		
		return @@index
	end
	
	private_class_method :new
end

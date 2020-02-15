require 'pg'
require_relative 'Api.rb'
require_relative 'Array.rb'

##
# Classe permettant d'accéder à la base de donnée (PostgreSQL) du bot.

class Bdd
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @conn		=> Connexion à la BDD (PG::Connexion)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouvel accès à la BDD de nom donné (<tt>"FlashNewsBot"</tt> par
	# défaut). Un serveur PostgreSQL doit être installé sur la machine sur
	# laquelle est exécuté le script et la table de nom donné doit être créée et
	# initialisé à l'aide du script SQL inclus dans les sources du projet.
	#
	# Paramètres :
	# [+dbname+]    Nom de la base de données (String, par défaut
	#               <tt>"FlashNewsBot"</tt>)
	def initialize(dbname = "FlashNewsBot")
		@conn = PG.connect(dbname: dbname)
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Enregistre le compte Twitter de +username+ donné dans la base de données.
	#
	# Retourne l'<tt>id</tt> du compte dans la base de données (Integer).
	#
	# Paramètres :
	# [+username+]      Nom d'utilisateur du compte Twitter (String)
	# [+api_key+]       Clé de l'API Twitter (String)
	# [+api_secret+]    Clé secrète de l'API Twitter (String)
	def new_twitter_api(username, api_key, api_secret)
		requete("INSERT INTO apis(domaine, username) VALUES ('twitter.com', " +
		        "'#{username}');")
		id = requete("SELECT id FROM apis WHERE domaine = 'twitter.com' AND " +
		             "username = '#{username}';")[0]["id"].to_i
		requete("INSERT INTO twitter_apis(api_id, username, api_key, " +
		        "api_secret) VALUES (#{id}, '#{username}', '#{api_key}', " + "'#{api_secret}');")
		return id
	end
	
	##
	# Retourne un Hash contenant les informations du compte Twitter recherchée
	# dans la table +twitter_apis+ :
	# [+id+]            Identifiant de l'application dans la base de données
	#                   (Integer)
	# [+username+]      Nom d'utilisateur (String)
	# [+api_key+]       Clé de l'API (String)
	# [+api_secret+]    Clé secrète de l'API (String)
	#
	# Retourne +nil+ si l'application n'existe pas dans la table.
	#
	# Paramètres :
	# [+username+]      Nom d'utilisateur du compte (String)
	def twitter_api(username)
		begin
			return requete("SELECT * FROM twitter_apis WHERE username = " +
			               "'#{username}';")[0]
		rescue IndexError
			return nil
		end
	end
	
	private
	
	# Effectue une requête SQL dans la base et renvoie le résultat (PG::Result).
	def requete(requete)
		return @conn.exec(requete)
	end
	
end

require 'pg'
require_relative 'Api.rb'

##
# Classe représentant la base de données du bot
#
# La base de données doit être préalablement créée dans PostgreSQL, de nom
# "FlashNewsBot", à l'aide des scripts présents dans le répertoire bdd.

class Bdd
	
	# @conn		=> Connexion à la BDD
	
	def initialize
		@conn = PG.connect(dbname: "FlashNewsBot")
	end
	
	##
	# Effectue une requête SQL dans la base et renvoie le résultat.
	
	def requete(requete)
		return @conn.exec(requete)
	end
	
	##
	# Enregistre une application dans la base.
	
	def enregistrer_app(type,
	                    domaine,
	                    api_key,
	                    api_secret,
	                    oauth_token,
	                    oauth_token_secret)
		case type
		when ApiType::TWITTER
			chaine_type = 'twitter'
		end
		
		requete("INSERT INTO application(type, domaine, api_key, api_secret,
		        oauth_token, oauth_token_secret) VALUES ('" + chaine_type +
		        "', '" + domaine + "', '" + api_key + "', '" + api_secret +
		        "', '" + oauth_token + "', '" + oauth_token_secret + "');")
		
		res = requete("SELECT id FROM application WHERE domaine = '" + domaine +
		              "';")
		id = res[0].values_at("id")
		return id[0]
	end
	
end

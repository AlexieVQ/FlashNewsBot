require 'pg'
require_relative 'Api.rb'
require_relative 'Array.rb'
=begin
require_relative 'Accroche.rb'
require_relative 'Localite.rb'
require_relative 'Pers.rb'
require_relative 'NomPers.rb'
require_relative 'Surnom.rb'
require_relative 'Parti.rb'
require_relative 'Media.rb'
require_relative 'DateInfo.rb'
require_relative 'Lieu.rb'
require_relative 'Info.rb'
require_relative 'Action.rb'
require_relative 'Circo.rb'
require_relative 'Decla.rb'
=end

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
	                    username,
	                    api_key,
	                    api_secret)
		case type
		when ApiType::TWITTER then
			chaine_type = 'twitter'
		end
		
		requete("INSERT INTO application(type, domaine, username, api_key,
		        api_secret) VALUES ('#{chaine_type}', '#{domaine}',
		        '#{username}', '#{api_key}', '#{api_secret}');")
		
		res = requete("SELECT id FROM application WHERE domaine =
		              '#{domaine}' AND username = '#{username}';")
		if res.ntuples != 0 then
			id = res[0].fetch("id").to_i
		else
			id = nil
		end
		return id
	end
	
	##
	# Pour un domaine et un username donné, inscrit les tokens de l'app dans la
	# table de hachage.
	
	def app(domaine, username, hash)
		res = requete("SELECT * FROM application WHERE domaine = '#{domaine}'
		              AND username = '#{username}';")
		if res.ntuples != 0 then
			hash[:api_key] = res[0].fetch("api_key")
			hash[:api_secret] = res[0].fetch("api_secret")
			return res[0].fetch("id").to_i
		else
			return nil
		end
	end
	
end

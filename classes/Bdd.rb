require 'pg'
require 'date'

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
	# Paramètres :
	# [+id+]            Identifiant du compte Twitter par l'API (Integer)
	# [+username+]      Nom d'utilisateur du compte Twitter (String)
	# [+api_key+]       Clé de l'API Twitter (String)
	# [+api_secret+]    Clé secrète de l'API Twitter (String)
	def new_compte_twitter(id, username, api_key, api_secret)
		requete("INSERT INTO comptes(id, domaine, username) VALUES (#{id},
		        'twitter.com', '#{username}');")
		requete("INSERT INTO comptes_twitter(compte_id, domaine, api_key,
		        api_secret) VALUES (#{id}, 'twitter.com', '#{api_key}', 
		        '#{api_secret}');")
		return self
	end
	
	##
	# Retourne un Hash contenant les informations du compte Twitter recherché
	# dans la table +comptes_twitter+ :
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
	def compte_twitter(username)
		begin
			res0 = requete("SELECT * FROM comptes WHERE username = '#{username}'
			               AND domaine = 'twitter.com';")[0]
			res1 = requete("SELECT * FROM comptes_twitter WHERE compte_id =
			               #{res0['id']} AND domaine = 'twitter.com';")[0]
			return {
				id: res0['id'],
				username: res0['username'],
				api_key: res1['api_key'],
				api_secret: res1['api_secret']
			}
		rescue IndexError
			return nil
		end
	end
	
	##
	# Enregistre le status d'id donné dans la base de données.
	#
	# Paramètres :
	# [+id+]            Identifiant du status par l'API du réseau social
	#                   (Integer)
	# [+compte+]        Compte ayant posté le status
	# [+created_at+]    \Date de création du status (String)
	# [+info+]          Info utilisée dans le status
	# [+pers+]          Personnages utilisées dans le status (Array de Pers)
	def insert_status(id, compte, created_at, info, pers)
		requete("INSERT INTO statuses(id, compte_id, domaine, created_at,
		        id_info) VALUES (#{id}, #{compte.id}, '#{compte.domaine}',
		        '#{DateTime.parse(created_at)}', #{info.id});")
		pers.each do |perso|
			requete("INSERT INTO pers(status_id, compte_id, domaine, id_pers)
			        VALUES (#{id}, #{compte.id}, '#{compte.domaine}',
			        #{perso.id});")
		end
		return self
	end
	
	##
	# Met à jour les informations du status d'id donné dans la base de données.
	#
	# Paramètres :
	# [+id+]        Identifiant du status par l'API du réseau social (Integer)
	# [+compte+]    Compte ayant posté le status
	# [+partages+]  Nombre de partages du status (Integer)
	# [+likes+]     Nombre de likes du status (Integer)
	# [+reponses+]  Nombre de réponses du status (Integer, +nil+ si
	#               indisponible)
	def update_status(id, compte, partages, likes, reponses = nil)
		requete("UPDATE statuses SET likes = #{likes}, partages = #{partages}
		        #{(reponses ? ", reponses = #{reponses}" : "")} WHERE id = #{id}
		        AND compte_id = #{compte.id} AND domaine = 
		        '#{compte.domaine}';")
		return self
	end
	
	##
	# Retourne le nombre de fois (Integer) que l'information donnée a été postée
	# sur le compte donné dans les dernières heures.
	#
	# Paramètres :
	# [+info+]          Info à rechercher
	# [+compte+]        Compte sur lequel rechercher
	# [+intervalle+]    Nombre d'heures sur lesquelles chercher (Integer)
	def info_recemment_poste(info, compte, intervalle = 24)
		return requete("SELECT * FROM statuses WHERE id_info = #{info.id} AND
		               compte_id = #{compte.id} AND domaine =
		               '#{compte.domaine}' AND created_at > date 'now' - 
		               interval '#{intervalle} hours';").ntuples
	end
	
	##
	# Retourne le nombre de fois (Integer) que le personnage donné a été posté
	# sur le compte donné dans les dernières heures.
	#
	# Paramètres :
	# [+pers+]          Pers à rechercher
	# [+compte+]        Compte sur lequel rechercher
	# [+intervalle+]    Nombre d'heures sur lesquelles chercher (Integer)
	def pers_recemment_poste(pers, compte, intervalle = 24)
		return requete("SELECT * FROM statuses JOIN pers ON (statuses.id =
		               pers.status_id AND statuses.compte_id = pers.compte_id
		               AND statuses.domaine = pers.domaine) WHERE id_pers =
		               #{pers.id} AND statuses.compte_id = #{compte.id} AND
		               statuses.domaine = '#{compte.domaine}' AND created_at >
		               date 'now' - interval '#{intervalle} hours';").ntuples
	end
	
	##
	# Retourne le nombre moyen d'interactions générées par status par
	# l'information donnée (Integer).
	#
	# Paramètres :
	# [+info+]      Info à rechercher
	# [+compte+]    Compte sur lequel chercher
	def interactions_info(info, compte)
		likes = requete("SELECT sum(likes) FROM statuses WHERE compte_id =
		                #{compte.id} AND domaine = '#{compte.domaine}' AND
		                id_info = #{info.id};")[0]['sum'].to_i
		partages = requete("SELECT sum(partages) FROM statuses WHERE compte_id =
		                   #{compte.id} AND domaine = '#{compte.domaine}' AND
		                   id_info = #{info.id};")[0]['sum'].to_i
		reponses = requete("SELECT sum(reponses) FROM statuses WHERE compte_id =
		                   #{compte.id} AND domaine = '#{compte.domaine}' AND
		                   id_info = #{info.id};")[0]['sum'].to_i
		status = requete("SELECT count(id) FROM statuses WHERE compte_id =
		                 #{compte.id} AND domaine = '#{compte.domaine}' AND
		                 id_info = #{info.id};")[0]['count'].to_i
		begin
			return ((likes + partages + reponses) / status).to_i
		rescue ZeroDivisionError
			return 0
		end
	end
	
	##
	# Retourne le nombre moyen d'interactions générées par status par
	# le personnage donné (Integer).
	#
	# Paramètres :
	# [+pers+]      Pers à rechercher
	# [+compte+]    Compte sur lequel chercher
	def interactions_pers(pers, compte)
		likes = requete("SELECT sum(likes) FROM statuses JOIN pers ON
		                (statuses.compte_id = pers.compte_id AND
		                statuses.domaine = pers.domaine AND statuses.id =
		                pers.status_id) WHERE statuses.compte_id = #{compte.id}
		                AND statuses.domaine = '#{compte.domaine}' AND id_pers =
		                #{pers.id};")[0]['sum'].to_i
		partages = requete("SELECT sum(partages) FROM statuses JOIN pers ON
		                   (statuses.compte_id = pers.compte_id AND
		                   statuses.domaine = pers.domaine AND statuses.id =
		                   pers.status_id) WHERE statuses.compte_id =
		                   #{compte.id} AND statuses.domaine =
		                   '#{compte.domaine}' AND id_pers = #{pers.id};"
		                  )[0]['sum'].to_i
		reponses = requete("SELECT sum(reponses) FROM statuses JOIN pers ON
		                   (statuses.compte_id = pers.compte_id AND
		                   statuses.domaine = pers.domaine AND statuses.id =
		                   pers.status_id) WHERE statuses.compte_id =
		                   #{compte.id} AND statuses.domaine =
		                   '#{compte.domaine}' AND id_pers = #{pers.id};"
		                  )[0]['sum'].to_i
		status = requete("SELECT count(statuses.id) FROM statuses JOIN pers ON
		                 (statuses.compte_id = pers.compte_id AND
		                 statuses.domaine = pers.domaine AND statuses.id =
		                 pers.status_id) WHERE statuses.compte_id = #{compte.id}
		                 AND statuses.domaine = '#{compte.domaine}' AND id_pers
		                 = #{pers.id};")[0]['count'].to_i
		begin
			return ((likes + partages + reponses) / status).to_i
		rescue ZeroDivisionError
			return 0
		end
	end
	
	private
	
	# Effectue une requête SQL dans la base et renvoie le résultat (PG::Result).
	def requete(requete)
		return @conn.exec(requete)
	end
	
end

require 'pg'
require_relative 'Api.rb'
require_relative 'Array.rb'
require_relative 'Accroche.rb'
require_relative 'Structure.rb'
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
		when ApiType::TWITTER then
			chaine_type = 'twitter'
		end
		
		requete("INSERT INTO application(type, domaine, api_key, api_secret,
		        oauth_token, oauth_token_secret) VALUES ('#{chaine_type}',
		        '#{domaine}', '#{api_key}', '#{api_secret}', '#{oauth_token}',
		        '#{oauth_token_secret}');")
		
		res = requete("SELECT id FROM application WHERE domaine =
		              '#{domaine}';")
		id = res[0].fetch("id")
		return id
	end
	
	##
	# Retourne le tableau des accroches
	
	def accroches
		res = requete("SELECT * FROM accroche;")
		tab = []
		res.each do | tuple |
			tab.push(Accroche.creer(tuple.fetch("id"),
			                        tuple.fetch("accroche"),
			                        tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne le tableau des structures
	
	def structures
		res = requete("SELECT * FROM structure;")
		tab = []
		res.each do | tuple |
			tab.push(Structure.creer(tuple.fetch("id"),
			                         tuple.fetch("structure"),
			                         tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne le tableau des localités.  
	# type est un tableau qui contient les types attendus 'region', 'pays',
	# 'ville', ou nil si tous les types sont attendus.  
	# nom_colle est la valeur de l'attribut nom_colle de la localité recherchée
	# précisément.  
	# id est la valeur de l'identifiant de la localité recherchée précisément.
	
	def localites(type = nil, nom_colle = nil, id = nil)
		if type && type.length then
			regle_type = "type IN ('#{type.join("', '")}')";
		else
			regle_type = "true"
		end
		
		if nom_colle then
			regle_nom = "nom_colle = '#{nom_colle}'"
		else
			regle_nom = "true"
		end
		
		if id != nil then
			regle_id = "id = #{id}"
		else
			regle_id = "true"
		end
		
		res = requete("SELECT * FROM localite WHERE #{regle_type} AND
		              #{regle_nom} AND #{regle_id};")
		tab = []
		res.each do | tuple |
			tab.push(Localite.creer(tuple.fetch("id"),
			                        tuple.fetch("type"),
			                        tuple.fetch("nom"),
			                        tuple.fetch("poids"),
			                        tuple.fetch("nom_en"),
			                        tuple.fetch("nom_colle"),
			                        tuple.fetch("adjm"),
			                        tuple.fetch("adjf"),
			                        tuple.fetch("departement"),
			                        tuple.fetch("emoji")))
		end
		return tab
	end
	
	##
	# Recherche une localité d'identifiant donné dans la base.
	
	def localite(id)
		if id != nil then
			return self.localites(id: id)[0]
		else
			return nil
	end
	
	##
	# Retourne le nom d'une catégorie d'identifiant donné.
	
	def categorie(id)
		res = requete("SELECT nom FROM categorie WHERE id = #{id};")
		if res.length then
			return res[0].fetch("nom")
		else
			return nil
		end
	end
	
	##
	# Retourne l'identifiant d'une catégorie de nom donné.
	
	def id_cat(categorie)
		res = requete("SELECT id FROM categorie WHERE nom = '#{categorie}';")
		if res.length then
			return res[0].fetch("id")
		else
			return nil
		end
	end
	
	##
	# Retourne la liste des catégories d'une information.
	
	def cat_info(id_info)
		res = requete("SELECT nom FROM cat_info JOIN categorie ON
		              (cat_info.id_cat = categorie.id) WHERE id_info =
		              #{id_info};")
		tab = []
		res.each do | tuple |
			tab.push(tuple.fetch("nom"))
		end
		return tab
	end
	
	##
	# Retourne le tableau des personnages.  
	# genre est le genre des personnages, nil pour tous les personnages
	# recherchés.  
	# categories est un tableau de catégories (chaînes de caractères) dont les
	# pondérations des personnages recherchées seront augmentées.
	
	def pers(genre = nil, categories = nil)
		if genre then
			regle_genre = "genre = '#{genre}'"
		else
			regle_genre = "true"
		end
		
		ids_cat = []
		if categories then
			categories.each do | categorie |
				ids_cat.push(id_cat(categorie))
			end
		end
		
		res = requete("SELECT * FROM pers WHERE #{regle_genre};")
		tab = []
		res.each do | tuple |
			categorie = self.categorie(tuple.fetch("id_cat"))
			tab.push(Pers.creer(tuple.fetch("id"),
			                    self.noms_pers(tuple.fetch("id")),
			                    self.surnoms(tuple.fetch("id")),
			                    tuple.fetch("poids") *
			                    	(categories.include?(categorie) ? 10 : 1),
			                    tuple.fetch("nom_colle"),
			                    tuple.fetch("genre"),
			                    categorie),
			                    localite(tuple.fetch("id_pays")),
			                    self.declas(id_pers: tuple.fetch("id")))
		end
		return tab
	end
	
	##
	# Retourne le tableau des noms pour un identifiant de personnage donné.
	
	def noms_pers(id_pers)
		res = requete("SELECT * FROM nom_pers WHERE id_pers = #{id_pers};")
		tab = []
		res.each do | tuple |
			tab.push(NomPers.creer(tuple.fetch("id"),
			                       tuple.fetch("nom"),
			                       tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne le tableau des surnoms pour un identifiant de personnage donné.
	
	def surnoms(id_pers)
		res = requete("SELECT * FROM surnom WHERE id_pers = #{id_pers};")
		tab = []
		res.each do | tuple |
			tab.push(Surnom.creer(tuple.fetch("id"),
			                      tuple.fetch("surnom"),
			                      tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne le tableau des organisations politiques.  
	# Si types est indiqué, seules les organisations de type présent dans ce
	# tableau seront choisies.
	
	def partis(types = [])
		if types.length then
			regle_type = "type IN ('#{types.join("', '")}')"
		else
			regle_type = "true"
		end
		
		res = requete("SELECT * FROM parti WHERE #{regle_type};")
		tab = []
		res.each do | tuple |
			tab.push(Parti.creer(tuple.fetch("id"),
			                     tuple.fetch("nom"),
			                     tuple.fetch("sigle"),
			                     tuple.fetch("type"),
			                     tuple.fetch("poids"),
			                     tuple.fetch("adjm"),
			                     tuple.fetch("adjf"),
			                     localite(tuple.fetch("localite"))))
		end
		return tab
	end
	
	##
	# Retourne la liste des médias.
	
	def medias
		res = requete("SELECT * FROM media;")
		tab = []
		res.each do | tuple |
			tab.push(Media.creer(tuple.fetch("id"),
			                     tuple.fetch("nom"),
			                     tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne la liste des dates.
	
	def dates
		res = requete("SELECT * FROM date;")
		tab = []
		res.each do | tuple |
			tab.push(DateInfo.creer(tuple.fetch("id"),
			                        tuple.fetch("date"),
			                        tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne la liste des lieux.
	
	def lieux
		res = requete("SELECT * FROM lieu;")
		tab = []
		res.each do | tuple |
			tab.push(Lieu.creer(tuple.fetch("id"),
			                    tuple.fetch("lieu"),
			                    tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne la liste des informations.  
	
	def infos
		res = requete("SELECT * FROM info;")
		tab = []
		res.each do | tuple |
			tab.push(Info.creer(tuple.fetch("id"),
			                    self.actions(tuple.fetch("id")),
			                    tuple.fetch("poid"),
			                    self.circos(tuple.fetch("id")),
			                    self.declas(tuple.fetch("decla")),
			                    tuple.fetch("hashtag"),
			                    tuple.fetch("type_circo"),
			                    self.cat_info(tuple.fetch("id"))))
		end
		return tab
	end
	
	##
	# Retourne la liste des actions d'une information.
	
	def actions(id_info)
		res = requete("SELECT * FROM action WHERE id_info = #{id_info};")
		tab = []
		res.each do | tuple |
			tab.push(Action.creer(tuple.fetch("id"),
			                      tuple.fetch("action"),
			                      tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne la liste des circonstances.  
	# id_info représente l'identifiant d'une information pour une circonstance
	# spécifique.  
	# type représente le type de circonstance recherché.
	
	def circos(id_info = nil, type = "universel")
		if id_info != nil then
			if type == "universel" then
				type = "specifique"
			end
			regle_info = "id_info = #{id_info}"
		else
			regle_info = "id_info IS NULL"
		end
		
		case type
		when "specifique" || "universel" || "accusation" then
			regle_type = "type_circo = '#{type}'"
		when "accuse" || "est_accuse" then
			regle_type = "type_circo IN ('#{type}', 'accusation')"
		else
			regle_type = "true"
		end
		
		res = requete("SELECT * FROM circo WHERE #{regle_info} AND
		              #{regle_type};")
		tab = []
		res.each do | tuple |
			tab.push(Circo.creer(tuple.fetch("id"),
			                     tuple.fetch("circo"),
			                     tuple.fetch("poids")))
		end
		return tab
	end
	
	##
	# Retourne la liste des déclarations pour une information ou un personnage
	# donné.
	
	def declas(id_info = nil, id_pers = nil)
		if id_info != nil then
			regle_info = "id_info = #{id_info}"
		else
			regle_info = "id_info IS NULL"
		end
		
		if id_pers != nil then
			regle_pers = "id_pers = #{id_pers}"
		else
			regle_pers = "id_pers IS NULL"
		end
		
		res = requete("SELECT * FROM decla WHERE #{regle_info} AND
		              #{regle_pers};")
		tab = []
		res.each do | tuple |
			tab.push(Decla.creer(tuple.fetch("id"),
			                     tuple.fetch("decla"),
			                     tuple.fetch("poids")))
		end
		return tab
	end
	
end

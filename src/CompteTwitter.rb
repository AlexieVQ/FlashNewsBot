require 'net/http'
require 'oauth'
require 'json'
require 'base64'
require_relative 'Compte.rb'
require_relative 'Bot.rb'
require_relative 'Bdd.rb'
require_relative 'ImageVolumineuseError.rb'

##
# Compte Twitter.

class CompteTwitter < Compte
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Crée un nouvel accès à l'API pour le compte d'<tt>username</tt> donné. Si
	# le compte n'existe pas dans la base de données, les clés de l'API sont
	# demandées dans la console. Puis il est demandé d'ouvrir le lien donné sur
	# un navigateur, de s'authentifier sur Twitter et de copier dans la console
	# le code obtenu. Si le compte existe déjà dans la base de données, seule
	# l'authentification est demandée.
	#
	# Paramètres :
	# [+username+]  Nom d'utilisateur (String)
	def CompteTwitter.connecter(username)
		if(compte = Bot.bdd.compte_twitter(username)) then
			return new(username, compte[:api_key], compte[:api_secret],
			           compte[:id])
		else
			print "Clé d'API : "
			api_key = gets.chomp
			print "Clé secrète d'API : "
			api_secret = gets.chomp
			return new(username, api_key, api_secret)
		end
		
	end
	
	#######################
	# VARIABLES DE CLASSE #
	#######################
	
	# @api_key		=> Clé de l'API Twitter (String)
	# @api_secret	=> Clé secrète de l'API Twitter (String)
	# @access_token	=> Token d'accès à l'API (OAuth::AccessToken)
	# @tendances	=> Tendances (Array de String)
	# @tendances_ts	=> Moment auquel les tendances ont été téléchargées (Time)
	# @id_pays		=> Id du pays pour les tendances (Integer)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouvel accès au compte Twitter d'<tt>username</tt> donné et
	# s'authentifie auprès de Twitter.
	#
	# *Attention* : la classe ne peut être instanciée hors de la classe
	# CompteTwitter. Utiliser CompteTwitter::connecter.
	#
	# Paramètres :
	# [+username+]      Nom d'utilisateur (String)
	# [+api_key+]       Clé d’API Twitter (String)
	# [+api_secret+]    Clé secrète d'API Twitter (String)
	# [+id+]            Identifiant du compte Twitter par l'API (Integer). +nil+
	#                   si le compte Twitter n'est pas présent dans la base de
	#                   données.
	def initialize(username, api_key, api_secret, id = nil)
		@username = username
		@api_key = api_key
		@api_secret = api_secret
		consumer = OAuth::Consumer.new(@api_key,
		                               @api_secret,
		                               {:site => "https://api.twitter.com",
		                               :scheme => :header})
		request_token = consumer.get_request_token(:oauth_callback => 'oob')
		oauth_token = request_token.token
		oauth_token_secret = request_token.secret
		url = request_token.authorize_url(:oauth_callback => 'oob')
		
		# Demande à l'utilisateur d'ouvrir l'URL, d'autoriser l'application et
		# d'écrire le code obtenu dans le terminal
		
		puts "Ouvrez " + url + " dans votre navigateur et autorisez " +
			"l'application."
		print "Code obtenu : "
		oauth_verifier = gets.chomp
		hash = {
			oauth_token: oauth_token,
			oauth_token_secret: oauth_token_secret
		}
		request_token = OAuth::RequestToken.from_hash(consumer, hash)
		@access_token = request_token.get_access_token(
			{:oauth_verifier => oauth_verifier,
		     :oauth_token => oauth_token,
		     :oauth_token_secret => oauth_token_secret}
		)
		if(id) then
			@id = id
		else
			reponse = @access_token.get("https://api.twitter.com/1.1/users/" +
			                            "show.json?screen_name=#{username}")
			unless(reponse == Net::HTTPSuccess) then
				reponse.value
			end
			unless(@id = JSON.parse(reponse.body)['id']) then
				raise "Mauvais nom d'utilisateur : \"#{username}\""
			end
			Bot.bdd.new_compte_twitter(@id, username, @api_key, @api_secret)
		end
	end
	
	############
	# MÉTHODES #
	############
	
	##
	# Envoie le status sur le compte Twitter et le stocke dans la base de
	# données (Retourne son id, Integer).
	#
	# Paramètres :
	# [+status+]    Status
	def envoyer(status)
		media_ids = status.images.reduce([]) { |tab, image|
			begin
				tab << envoyer_image(image)
			rescue ImageVolumineuseError => e
				$stderr.puts(e.full_message)
			end
			tab
		}
		reponse = @access_token.post(
			"https://api.twitter.com/1.1/statuses/update.json",
			{status: status.texte,
			 media_ids: media_ids.join(','),
			 possibly_sensitive: false})
		
		unless(reponse == Net::HTTPSuccess) then
			reponse.value
		end
		tweet = JSON.parse(reponse.body)
		# Bot.bdd.insert_status(tweet["id"].to_i, self, tweet["created_at"],
		# 					  status.info, status.pers)
		return tweet["id"].to_i
	end
	
	##
	# Met à jour les statistiques des status envoyés les 5 derniers jours dans
	# la base de données.
	def update_statuses
		count = ((60 / Bot.intervalle) * 24 * 5).to_i # Nombre de status envoyés
		                                              # en 5 jours
		count = 3200 if(count > 3200)
		reponse = @access_token.get("https://api.twitter.com/1.1/statuses/" +
		                            "user_timeline.json?" +
		                            "screen_name=#{@username}&" +
		                            "count=#{count}&include_rts=false&" +
		                            "exclude_replies=true")
		unless(reponse == Net::HTTPSuccess) then
			reponse.value
		end
		tweets = JSON.parse(reponse.body)
		tweets.each { |tweet|
			Bot.bdd.update_status(tweet['id'].to_i, self,
			                      tweet['retweet_count'].to_i,
			                      tweet['favorite_count'].to_i)
		}
		return self
	end
	
	##
	# Pour chaque mention non lue, envoie la réponse données.
	#
	# Exemple d'utilisation :
	#	compte.repondre { |mention| # String contenant le texte du statut
	#		"Voici ma réponse au statut #{mention}"
	#	}
	#
	# Seule les mentions répondant à un statut du compte sont listées.
	# Si la fonction renvoie +nil+ ou une chaîne vide, ne répond pas au statut.
	#
	# Paramètres :
	# [+taux+]  Taux de mentions à traiter (Integer de 0 à 100 inclus)
	def repondre(taux = 100)
		reponse = @access_token.get("https://api.twitter.com/1.1/statuses/" +
									"mentions_timeline.json")
		unless(reponse == Net::HTTPSuccess) then
			reponse.value
		end
		mentions = JSON.parse(reponse.body)
		mentions.each { |mention|
			if(!Bot.bdd.lue?(mention['id'], self) &&
				Bot.bdd.status_existe?(mention['in_reply_to_status_id'].to_i,
				self) && rand(100) < taux) then
				rep = yield(mention['text'].gsub(/@\w*/, ""))
				unless(rep.to_s.empty?) then
					puts rep if(Bot.debug?)
					reponse = @access_token.post(
						"https://api.twitter.com/1.1/statuses/update.json",
						{status: "@#{mention['user']['screen_name']} #{rep}",
						in_reply_to_status_id: mention['id']})
					unless(reponse == Net::HTTPSuccess) then
						reponse.value
					end
				end
			end
		}
		return self
	end
	
	##
	# Limite de caractères d'un status (Integer)
	def limite
		return 280
	end
	
	##
	# Taille maximale d'une image (octets, Integer)
	def taille_image
		return 5000000
	end
	
	##
	# <tt>"twitter.com"</tt> (String)
	def domaine
		return "twitter.com"
	end
	
	##
	# Retourne les tendances française (Array de String).
	#
	# Met à jour les tendances toutes les heures.
	def tendances
		if(@tendances.nil? || (Time.now - 3600) > @tendances_ts) then
			if(@id_pays.nil?) then
				reponse_pays = @access_token.get(
					"https://api.twitter.com/1.1/trends/available.json")
				unless(reponse_pays == Net::HTTPSuccess) then
					reponse_pays.value
				end
				liste_pays = JSON.parse(reponse_pays.body)
				@id_pays = liste_pays.reduce { |id, pays|
					if(pays['countryCode'] == "FR") then
						id = pays['woeid']
					end
					id
				}
				if(@id_pays.nil?) then
					raise "WOEID de la France non trouvé pour le compte #{self}"
				end
			end
			
			reponse_tendances = @access_token.get(
				"https://api.twitter.com/1.1/trends/place.json?id=#{@id_pays}")
			unless(reponse_tendances == Net::HTTPSuccess) then
				reponse_tendances.value
			end
			@tendances = JSON.parse(
				reponse_tendances.body)[0]['trends'].map { |td| td['name'] }
			@tendances_ts = Time.now
		end
		return @tendances
	end
	
	private
	
	##
	# Envoie l'image donnée sur Twitter et retourne son +media_id+ (String).
	#
	# Paramètres :
	# [+image+] Image ou ImageStatique à envoyer
	#
	# Lève une ImageVolumineuseError si l'image est trop volumineuse pour
	# Twitter.
	def envoyer_image(image)
		fichier = image.fichier
		if(fichier.size >= self.taille_image) then
			raise ImageVolumineuseError, "Image #{image.id} trop volumineuse " +
				"pour Twitter (#{fichier.size} octets)"
		end
		reponse = @access_token.post(
			"https://upload.twitter.com/1.1/media/upload.json?" +
			"media_category=TWEET_IMAGE",
		    {media_data: Base64.encode64(fichier.read)})
		unless(reponse == Net::HTTPSuccess) then
			reponse.value
		end
		id = JSON.parse(reponse.body)['media_id'].to_i
		reponse_alt = @access_token.post(
			"https://upload.twitter.com/1.1/media/metadata/create.json",
			JSON.generate({media_id: id, alt_text: {text: image.description}}),
			{'Content-Type' => 'application/json; charset=UTF-8'})
		unless(reponse_alt == Net::HTTPSuccess) then
			reponse_alt.value
		end
		return id
	end
end

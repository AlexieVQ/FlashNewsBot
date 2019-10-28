##
# Type d'API.

module ApiType
	## Twitter
	TWITTER = 1
end

##
# Classe représentant l’API du réseau social utilisé (Twitter pour l'instant,
# Mastodon à l’avenir), et les méthodes d'accès à cette API.

class Api
	
	# @instance		=> Nom de domaine du réseau social (ex : twitter.com)
	# @urlBase		=> URL de base de l'API (ex : https://api.twitter.com/)
	
	private_class_method :new
	
	##
	# Connexion à l'API
	
	def Api.connecter(type, nomInstance = "twitter.com")
		new(type, nomInstance)
	end
	
	def initialize(type, nomInstance)
		case type
		when ApiType::TWITTER
			@instance = "twitter.com"
			@urlBase = "https://api.twitter.com/"
		end
	end
end

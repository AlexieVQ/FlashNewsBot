require_relative 'Bot.rb'
require_relative 'Expression.rb'
require_relative 'ImageStatique.rb'
require_relative 'elements/Pers.rb'
require_relative 'elements/DateInfo.rb'
require_relative 'elements/Lieu.rb'
require_relative 'elements/Media.rb'

##
# Un status à envoyer au réseau social. Il se construit aléatoirement à la
# création.

class Status
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Texte du status (String)
	attr_reader :texte
	
	##
	# Information principale du status (Info)
	attr_reader :info
	
	##
	# Array de Pers présentes dans le status
	attr_reader :pers
	
	##
	# Images du status (Array d'Images)
	attr_reader :images
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouveau status de manière aléatoire.
	#
	# L'index est d'abord réinitialisé (voir Bot::index_reset). Une information
	# est stockée dans son entrée +info+. Si l'information a une structure
	# personnalisée (voir Info#structure), celle-ci est évaluée. Sinon un
	# personnage sujet de l'information est stocké dans +sujet+. L'action de
	# l'information (voir Info#action) est évaluée, avec possible ajout d'une
	# DateInfo et d'un Lieu. Ensuite une Accroche est ajouté en début de status,
	# puis une deuxième partie où le sujet réagit à l'information est
	# aléatoirement ajoutée, ou non. Cette partie incorpore Info#decla,
	# Pers#declas ou une déclaration universelle.
	def initialize
		begin
			Bot.sujet_surnomme = false
			@texte = ""
			@info = nil
			@pers = []
			@images = []
			Bot.index_reset
			
			# Choix de l'information principale du status
			Bot.index['info'] = Info.elt_alea
			
			# Cas où l'information a une structure personnalisée : on évalue la
			# structure
			if(Bot.index['info'].structure && Bot.index['info'].structure != "")
			then
				@texte = Bot.index['info'].structure.evaluer
			else
				# Choix du personnage sujet de l'information
				Bot.index['sujet'] = Pers.elt_alea
				
				# Génération de la partie information
				@texte = partie_info
				# Ajout de l'accroche
				@texte = Accroche.retourner(nil, [@texte, "sujet"])
				# Ajout de la deuxième partie du status, où le sujet prend la
				# parole
				if(rand(2) == 1) then
					@texte += " " + partie_decla
				end
			end
			@info = Bot.index['info']
			@pers = Bot.index.values.reduce([]) do |liste, element|
				if(element.kind_of? Pers) then
					liste << element
				end
				liste
			end
			
			@images = []
			if(Bot.index['sujet'] && Bot.index['sujet'].image) then
				@images << Bot.index['sujet'].image
			end
			if(Bot.index['info'].image) then
				@images << Bot.index['info'].image
			elsif(Bot.index['objet'] && Bot.index['objet'].image) then
				@images << Bot.index['objet'].image
			elsif(Bot.index['declarant'] && Bot.index['declarant'].image) then
				@images << Bot.index['declarant'].image
			end
			if(@images.length == 0) then
				@images << ImageStatique.elt_alea
			end
			
		rescue IndexError => e
			puts "#{e.message} : réessai" if(Bot.debug?)
			retry
		end
	end
	
	############
	# MÉTHODES #
	############
	
	##
	# Représente le status sous la forme <tt>[<em>Avertissements</em>]<em>Texte
	# du status</em> [<em>Description de de l'image</em> <em>URL de
	# l'image</em>]</tt>.
	def to_s
		chaine = self.cw? ? "[#{self.cw_string}] #{@texte}" : "#{@texte}"
		return @images.reduce(chaine) do |chaine, image|
			chaine + " " + image.to_s
		end
	end
	
	##
	# Retourne les avertissements de contenu pour le status (Array de String,
	# vide si aucun avertissement).
	def cw
		return Bot.index.values.reduce([]) { |tab, element|
			if(element.respond_to?(:cw) && element.cw?) then
				tab << element.cw
			end
			tab
		}
	end
	
	##
	# Retourne un avertissement de contenu pour le status (String, vide ou
	# +nil+, concaténation des résultats de Status#cw).
	def cw_string
		return self.cw.join(", ")
	end
	
	##
	# Teste si status a un avertissement de contenu (voir Status#cw).
	def cw?
		return self.cw.length > 0
	end
	
	private
	
	# Génère la partie principale contenant l'action de l'information et
	# éventuellement sa circonstance, son lieu...  
	# Le sujet n'est pas nommé.
	def partie_info
		chaine = Bot.index['info'].action
		
		if(rand(2) == 1) then
			chaine += " " + DateInfo.elt_alea.date
		end
		
		if(rand(2) == 1) then
			chaine += " " + Lieu.elt_alea.lieu
		end
		
		if(["accuse", "est_accuse",
		   "accusation"].include?(Bot.index['info'].type_circo) ||
		   rand(2) == 1) then
			chaine += " " + Bot.index['info'].circo
		end
		
		return chaine + "."
	end
	
	# Génère la partie contenant la déclaration du sujet, de l'objet ou d'un
	# personnage tierce, stocké dans +declarant+.
	def partie_decla
		declarant = Pers.elt_alea
		decla_type = :sujet
		if(Bot.index['objet'] && Bot.index['info'].decla_objet? && rand(2) == 1)
		then
			decla_type = :objet
		elsif(Bot.index['info'].decla_autre?(declarant) && rand(2) == 1) then
			decla_type = :autre
			Bot.index['declarant'] = declarant
		end
			
		chaine = ""
		case decla_type
		when :sujet then
			if(Bot.sujet_surnomme?) then
				chaine = Bot.index['sujet'].pronom.majuscule
			else
				chaine = Bot.index['sujet'].surnom.majuscule
				Bot.sujet_surnomme = true
			end
		when :objet then chaine = Bot.index['objet'].surnom.majuscule
		when :autre then chaine = declarant.nom.majuscule
		end
		
		chaine += " " + case rand(4)
		when 0 then "a déclaré"
		when 1 then "aurait déclaré"
		when 2 then "aurait dit"
		when 3 then "a réagi"
		end
		
		if(rand(2) == 1) then
			chaine += " " + DateInfo.elt_alea.date
		end
		
		if(rand(2) == 1) then
			chaine += " " + Media.elt_alea.nom("à")
		end
		
		case rand(6)
		when 0 then chaine += " à ce sujet"
		when 1 then chaine += " au sujet de " + Bot.index['info'].type
		when 2 then chaine += " à propos de " + Bot.index['info'].type
		end
		
		case decla_type
		when :sujet then chaine += " “" + Bot.index['info'].decla_sujet + "”"
		when :objet then chaine += " “" + Bot.index['info'].decla_objet + "”"
		when :autre then chaine += " “" +
			Bot.index['info'].decla_autre(declarant) + "”"
		end
		return chaine + "."
	end
	
end

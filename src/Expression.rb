require_relative 'Bot.rb'
require_relative 'String.rb'
require_relative 'Enumerable.rb'

##
# Les expressions sont présentes dans les chaînes de caractères contenues dans
# les tables pour produire un résultat différent selon le contexte. Elle sont
# définies entre accolades.
#
# Les expressions permettent par exemple d'invoquer un nouvel Element dans
# l'information comme un nouveau personnage (<tt>{p=pers}{p.nom}</tt> crée un
# personnage +p+ et affiche son nom), un lieu, une déclaration...
#
# D'autres expressions plus simples permettent par exemple de choisir
# aléatoirement une chaîne de caractères, de la mettre en majuscules... Ces
# commandes sont définies dans la classe Expression.

class Expression
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Retourne une chaîne de caractère au hasard contenue dans +parametres+.
	#
	# Exemple :
	#	Je compte jusqu'à {rand(un,deux,trois,quatre)}.
	# peut produire le résultat suivant :
	#	Je compte jusqu'à trois.
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Array de String
	def Expression.rand(attribut, parametres)
		return parametres.elt_alea
	end
	
	##
	# Met la première lettre de <tt>parametres[0]</tt> en majuscule, sans
	# modifier le reste de la chaîne.
	#
	# Exemple :
	#	{maj(le Président de la République)}
	# produit le résultat suivant :
	#	Le Président de la République
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Array de String (seule la première valeur est prise en
	#                   compte)
	def Expression.maj(attribut, parametres)
		return parametres[0].majuscule
	end
	
	##
	# Met l'ensemble de la chaîne <tt>parametres[0]</tt> en majuscules.
	#
	# Exemple :
	#	{cap(Breaking news)}
	# produit le résultat suivant :
	#	BREAKING NEWS
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Array de String (seule la première valeur est prise en
	#                   compte)
	def Expression.cap(attribut, parametres)
		return parametres[0].upcase
	end
	
	##
	# Retourne la chaîne de caractère correspondante au genre du personnage
	# demandé.
	#
	# Exemple :
	#	{genre(p,l'homme,la femme)}
	# produit le résultat suivant si +p+ est une femme :
	#	la femme
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Array de String :
	#                   [<tt>parametres[0]</tt>]    Identifiant du personnage
	#                                               dans l'index
	#                   [<tt>parametres[1]</tt>]    Chaîne masculine
	#                   [<tt>parametres[2]</tt>]    Chaîne féminine
	#
	# Si le personnage n'est pas présent dans l'index, lève une *IndexError*.
	def Expression.genre(attribut, parametres)
		nom_pers = parametres[0]
		chaine_m = parametres[1]
		chaine_f = parametres[2]
		unless(Bot.index[nom_pers]) then
			raise IndexError, "#{nom_pers} absent de l'index"
		end
		if(Bot.index[nom_pers].genre == 'M') then
			return chaine_m
		elsif(Bot.index[nom_pers].genre == 'F') then
			return chaine_f
		else
			return nil
		end
	end
	
	##
	# Équivalent de <tt>{genre(sujet,,e)}</tt>. Ajoute un +e+ si le sujet est
	# féminin.
	#
	# Exemple :
	#	{sujet.nom} a été arrêté{gse}.
	# produit le résultat suivant si +sujet+ est Peach :
	#	Peach a été arrêtée.
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Ignoré
	def Expression.gse(attribut, parametres)
		return Expression.genre(attribut, ["sujet", "", "e"])
	end
	
	##
	# Ajoute un <tt>#</tt>, ou non. Équivalent de <tt>{rand(,#)}</tt>.
	#
	# Exemple :
	#	Emmanuel {h}Macron
	# peut produire l'un des résultats suivants :
	#	Emmanuel Macron
	#	Emmanuel #Macron
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Ignoré
	def Expression.h(attribut, parametres)
		return Expression.rand(attribut, ["", "#"])
	end
	
	##
	# Retourne un entier aléatoire (String) entre <tt>parametres[0]</tt> et
	# <tt>parametres[1]</tt> inclus.
	#
	# Exemple :
	#	l'acte {randn(1,52)} des Gilets Jaunes
	# peut produire le résultat suivant :
	#	l'acte 35 des Gilets Jaunes
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Array de String :
	#                   [<tt>parametres[0]</tt>]    Borne inférieure
	#                   [<tt>parametres[1]</tt>]    Borne supérieure
	def Expression.randn(attribut, parametres)
		return (parametres[0].to_i..parametres[1].to_i).to_a.sample.to_s
	end
	
	##
	# Retourne la localité principale (Localite) de l'information, c'est-à-dire
	# +loc_info+ si elle est définie, sinon celle du sujet ou du lieu.
	#
	# Paramètres :
	# [+attribut+]      Ignoré
	# [+parametres+]    Ignoré
	def Expression.loc_principale(attribut, parametres)
		if(Bot.index['loc_info']) then
			return Bot.index['loc_info']
		elsif(Bot.index['sujet'] && Bot.index['sujet'].localite) then
			return Box.index['sujet'].localite
		elsif(Bot.index['loc_lieu']) then
			return Bot.index['loc_lieu']
		end
		return nil
	end
	
	#######################
	# VARIABLE D'INSTANCE #
	#######################
	
	# @commande	=> Méthode à utiliser pour évaluer l'expression (Method)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une nouvelle Expression de méthode donnée.
	#
	# Paramètres :
	# [+methode+]   Symbole de la méthode à utiliser pour évaluer l'expression.
	#               Doit être une méthode de classe d'Expression. (Symbol)
	def initialize(methode)
		@commande = Expression.method(methode)
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne un String pour l'attribut et les paramètres donnés. Comportement
	# dépendant de la méthode choisie lors de la création de l'expression.
	#
	# Paramètres :
	# [+attribut+]      String
	# [+parametres+]    Array de String
	def retourner(attribut, parametres)
		return @commande.call(attribut, parametres)
	end
	
	##
	# Retourne le nom de la méthode utilisée (String).
	def to_s
		return @commande.to_s
	end
	
end

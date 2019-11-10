##
# Ajout à la classe String de la méthode évaluer, qui évalue une commande entre
# {} dans un élément.

class String
	
	## Évalue les commandes entre {}
	def evaluer
		res = self
		while res.scan(/{[^{}]+}/).length != 0 do
			res = res.gsub(/{[^{}]+}/) do | commande |
				commande.eval_commande
			end
		end
		return res
	end
	
	## Évaluer une commande
	def eval_commande
		# Nom de la variable à affecter
		if self.scan(/{\w+=/).length != 0 then
			nouv_var = self.scan(/{\w+=/)[0].scan(/\w+/)[0]
			# Commande principale
			com = self.scan(/=\w+/)[0].scan(/\w+/)[0]
		else
			com = self.scan(/{\w+/)[0].scan(/\w+/)[0]
		end
		
		# Attribut
		if self.scan(/\.\w+/).length != 0 then
			attribut = self.scan(/\.\w+/)[0].scan(/\w+/)[0]
		end
		
		# Paramètres
		parametres = []
		if self.scan(/\([^\(\)]*\)/).length != 0 then
			parametres = self.scan(/\([^\(\)]*\)/)[0].scan(/[^\(\)\,]+/)
		end
		
		# Demande à l'index
		if $index[com] == nil then
			raise "#{com} inconnu dans l'index (commande : #{self})"
		end
		resultat = $index[com].retourner(attribut, parametres)
		if nouv_var then
			if $index[nouv_var] == nil then
				$index[nouv_var] = resultat
			else
				raise "#{nouv_var} existe déjà dans l'index"
			end
			return ""
		else
			return resultat.to_s
		end
	end
	
	def modif_article(article)
		return self
	end
	
end

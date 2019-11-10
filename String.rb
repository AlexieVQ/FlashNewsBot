##
# Ajout à la classe String de la méthode évaluer, qui évalue une commande entre
# {} dans un élément.

class String
	
	## Évalue les commandes entre {}
	def evaluer
		res = self
		while res.scan(/{[^{}]+}/).length do
			res = res.gsub(/{[^{}]+}/) do | commande |
				commande.eval_commande
			end
		end
		return res
	end
	
	## Évaluer une commande
	def eval_commande
		# Nom de la variable à affecter
		if self.scan(/{\w+=/).length then
			nouv_var = self.scan(/{\w+=/)[0].scan(/\w/)[0]
			# Commande principale
			com = self.scan(/=\w+/)[0].scan(/\w/)[0]
		else
			com = self.scan(/{\w+/)[0].scan(/\w/)[0]
		end
		
		# Attribut
		if self.scan(/\.\w+/) then
			attribut = self.scan(/\.\w+/)[0].scan(/\w/)[0]
		end
		
		# Paramètres
		parametres = []
		if self.scan(/\([^\(\)]*\)/) then
			parametres = self.scan(/\([^\(\)]*\)/)[0].scan(/[^\(\)\,]+/)
		end
		
		# Demande à l'index
		resultat = $index[com].retourner(attribut, parametres)
		if nouv_var then
			if $index[nouv_var] == nil do
				$index[nouv_var] = resultat
			else
				raise "#{nouv_var} existe déjà dans l'index"
			end
		else
			return resultat.to_s
		end
	end
	
end

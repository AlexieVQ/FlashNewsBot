require "i18n"
require "levenshtein-ffi"

I18n.config.available_locales = :en

module Refinements
	
	refine String do
		
		# @return [Boolean]
		def voyelle?
			/\A([aeiouéèàêâôûùïî]|y([^aeiouéèàêâôûùïî]|\z))/i.match?(self)
		end

		# Calcule la distance de Levenshtein avec la chaîne donnée.
		# Le test est insensible à la case et aux accents.
		# @param chaine [String] Chaîne à comparer
		# @return [Integer] Nombre d'insertion, suppression ou remplacements
		#  entre les deux chaînes.
		def levenshtein(chaine)
			s1 = I18n.transliterate(self).downcase
			s2 = I18n.transliterate(self).downcase
			Levenshtein.distance(s1, s2)
		end

	end
end
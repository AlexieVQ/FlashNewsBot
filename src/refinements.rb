module Refinements
	
	refine String do
		
		# @return [Boolean]
		def voyelle?
			/\A([aeiouéèàêâôûùïî]|y([^aeiouéèàêâôûùïî]|\z))/i.match?(self)
		end

	end
end
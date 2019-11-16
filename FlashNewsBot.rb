#!/usr/share/ruby

require_relative 'Status.rb'
require_relative 'Bdd.rb'
require_relative 'Api.rb'

$bdd = Bdd.new

api = Api.connecter("FlashNewsTest")

loop do

	status = Status.creer

	puts status
	if status.texte.length <= api.limite then
		api.envoyer(status.texte)
	end
	
	sleep(10)
	
end

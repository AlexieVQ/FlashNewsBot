require_relative 'Status.rb'
require_relative 'Bdd.rb'
require_relative 'Api.rb'

$bdd = Bdd.new

#api = Api.connecter("FlashNewsTest")

status = Status.creer

puts status
puts "#{status.texte.length} caractères"
#api.envoyer(status.texte)

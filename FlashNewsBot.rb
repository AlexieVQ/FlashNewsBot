require_relative 'Status.rb'
require_relative 'Bdd.rb'

$bdd = Bdd.new

status = Status.creer

puts status

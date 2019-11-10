require_relative 'Commande.rb'
require_relative 'Bdd.rb'

$bdd = Bdd.new

$index = Hash.new

$index['rand'] = Commande.commande(TypeCommande::RAND)
$index['maj'] = Commande.commande(TypeCommande::MAJ)
$index['cap'] = Commande.commande(TypeCommande::CAP)
$index['genre'] = Commande.commande(TypeCommande::GENRE)
$index['gse'] = Commande.commande(TypeCommande::GSE)
$index['accroche'] = Commande.commande(TypeCommande::ACCROCHE)
$index['pers'] = Commande.commande(TypeCommande::PERS)
$index['date'] = Commande.commande(TypeCommande::DATE)
$index['lieu'] = Commande.commande(TypeCommande::LIEU)
$index['localite'] = Commande.commande(TypeCommande::LOCALITE)
$index['parti'] = Commande.commande(TypeCommande::PARTI)
$index['media'] = Commande.commande(TypeCommande::MEDIA)
$index['circo'] = Commande.commande(TypeCommande::CIRCO)
$index['decla'] = Commande.commande(TypeCommande::DECLA)

$index['info'] = $bdd.infos.elt_alea
$index['sujet'] = $bdd.pers(categories: $index['info'].categories).elt_alea

puts $bdd.structures.elt_alea.evaluer

##
# Classe représentant une erreur qui apparaît lorsqu'une entrée de l'index
# existe déjà ou n'existe pas.

class IndexErreur < StandardError; end

##
# Classe représentant une erreur qui apparaît lorsqu'il faut retourner un
# élément aléatoire d'un tableau vide.

class TableauVide < StandardError; end

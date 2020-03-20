# TODO

## Twitter

- [x] Vérifier l'unicité des éléments dans leur table
- [ ] Images
	- [x] Tester la taille des images
	- [x] Envoyer les images sur Twitter
	- [x] Description des images
	- [x] CW des images
	- [x] Image _Flash Info_
	- [ ] Associer des images aux personnages
	- [ ] Associer des images aux informations
	- [ ] Envoie des images de manière aléatoire
	- [ ] Compresser l'image statique
- [x] Analyse des tendances
	- [x] Recevoir les tendances
	- [x] Programme de test
	- [x] Chercher des bouts de chaîne dans une autre
	- [x] Influencer les pondérations
- [ ] CW de certains personnages
- [x] Déclarations d'autres personnes
- [x] Mode débuggage
	- [x] Sauvetage de toutes les erreurs au niveau du bot en mode production
- [x] Afficher élément concerné par erreur réseau
- [ ] Revenir sur le comptage du surnommage (reset le compteur à chaque status,
      donner le pronom manuellement ?)

## Mastodon

- [x] Gestion des content warnings
- [ ] Gestion de l'API Mastodon

## Erreurs

- [ ] Problème insertion de données existantes :
```
/home/alexie/Developpement/FlashNewsBot/src/Bdd.rb:227:in `exec': ERROR:  duplicate key value violates unique constraint "pers_pkey" (PG::UniqueViolation)
DETAIL:  Key (status_id, compte_id, domaine, id_pers)=(1238264552208424961, 1037678033887539200, twitter.com, 75) already exists.
	from /home/alexie/Developpement/FlashNewsBot/src/Bdd.rb:227:in `requete'
	from /home/alexie/Developpement/FlashNewsBot/src/Bdd.rb:98:in `block in insert_status'
	from /home/alexie/Developpement/FlashNewsBot/src/Bdd.rb:97:in `each'
	from /home/alexie/Developpement/FlashNewsBot/src/Bdd.rb:97:in `insert_status'
	from /home/alexie/Developpement/FlashNewsBot/src/CompteTwitter.rb:141:in `envoyer'
	from /home/alexie/Developpement/FlashNewsBot/src/Bot.rb:73:in `block in exec'
	from /home/alexie/Developpement/FlashNewsBot/src/Bot.rb:65:in `loop'
	from /home/alexie/Developpement/FlashNewsBot/src/Bot.rb:65:in `exec'
	from ./FlashNewsBot.rb:40:in `<main>'
```
- [ ] Énumération vide :
```
/home/alexie/Developpement/FlashNewsBot/src/Enumerable.rb:22:in `elt_alea': Énumération vide (RuntimeError)
	from /home/alexie/Developpement/FlashNewsBot/src/elements/Pers.rb:173:in `surnom'
	from /home/alexie/Developpement/FlashNewsBot/src/Status.rb:137:in `partie_decla'
	from /home/alexie/Developpement/FlashNewsBot/src/Status.rb:70:in `initialize'
	from /home/alexie/Developpement/FlashNewsBot/src/Bot.rb:67:in `new'
	from /home/alexie/Developpement/FlashNewsBot/src/Bot.rb:67:in `block in exec'
	from /home/alexie/Developpement/FlashNewsBot/src/Bot.rb:65:in `loop'
	from /home/alexie/Developpement/FlashNewsBot/src/Bot.rb:65:in `exec'
	from ./FlashNewsBot.rb:40:in `<main>'
```
- [ ] _de le_ :
> FLASH NEWS - Antoine Griezmann décide de rejoindre la République En Marche
> dans le métro suite à son départ de le parti Travailliste. Le footballer a
> déclaré hier dans le cadre de l’affaire Yann Moix “C’était pour déconner”.

# TODO

## Twitter

- [x] Vérifier l'unicité des éléments dans leur table
- [ ] Images
	- [x] Tester la taille des images
	- [x] Envoyer les images sur Twitter
	- [x] Description des images
	- [ ] CW des images
	- [ ] Associer des images aux personnages
	- [ ] Associer des images aux informations
- [ ] Analyse des tendances

## Mastodon

- [ ] Gestion des content warnings
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

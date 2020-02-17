# FlashNewsBot

Réécriture du [FlashNewsBot](https://twitter.com/FlashNewsBot "Twitter") en
Ruby.

## Exécution :

- Avoir un serveur PostgreSQL installé sur la machine, créer une base de données
  _FlashNewsBot_ et initialiser cette base à l'aide du script
  `bdd/creation.sql`.
- Pour une exécution hors-ligne, entrer `./FlashNewsBot.rb -o`.

## Gems requises :

- [csv](https://github.com/ruby/csv)
- [pg](https://github.com/ged/ruby-pg)
- [oauth](https://rubygems.org/gems/oauth)
- [json](https://flori.github.io/json/)
- [daemons](https://github.com/thuehlinger/daemons)

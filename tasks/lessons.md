# Lessons

- Quand un build Flutter casse dans des fichiers `app_localizations_*.dart`, verifier d'abord les fichiers source `.arb` et leurs placeholders avant de patcher le Dart genere: le build regenere ces fichiers et ecrase sinon le faux correctif.

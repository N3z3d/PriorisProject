# Lessons

- Quand un build Flutter casse dans des fichiers `app_localizations_*.dart`, verifier d'abord les fichiers source `.arb` et leurs placeholders avant de patcher le Dart genere: le build regenere ces fichiers et ecrase sinon le faux correctif.
- Avant d'annoncer qu'une URL publique reflete bien la derniere implementation, comparer explicitement l'etat du code officiel (`main` / remote) avec le worktree local: un poste local sale peut contenir le bon comportement alors que l'instance publiee sert encore un commit plus ancien.
- Quand une QA de shell Flutter est re-ecrite, la relancer sur viewport desktop et mobile: les tests alignes avec l'etat officiel revelem souvent de vrais overflows UI que les anciens tests obsoletes masquaient.

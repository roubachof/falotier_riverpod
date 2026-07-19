# Improvements

Propositions d'amélioration de l'architecture falotier. Chaque proposition vit dans un fichier Markdown autonome.

## Organisation des sous-dossiers

| Dossier | Rôle |
|---------|------|
| `./` (racine) | Propositions en cours de discussion, non encore validées |
| `validated/` | Propositions validées, prêtes à être implémentées |
| `implemented/` | Propositions implémentées dans le code (conservées pour référence et historique) |

## Cycle de vie d'une proposition

```
racine ──(validation)──► validated ──(implémentation)──► implemented
```

1. **Rédaction** — une proposition démarre à la racine. On la discute, on la raffine.
2. **Validation** — une fois qu'on est d'accord sur le quoi/comment, on déplace le fichier dans `validated/`. Il est prêt à être fait.
3. **Implémentation** — une fois le code modifié et les checks (`flutter analyze`, tests, vérification manuelle) passés, on déplace le fichier dans `implemented/`. On ne le supprime pas : il sert d'historique et de référence pour les propositions futures qui s'y réfèrent.

## Règles

- **Une proposition validée doit être implémentée avant d'aller dans `implemented/`.** Le code est la source de vérité ; le doc le suit, pas l'inverse.
- **Les docs dans `implemented/` ne sont pas modifiés a posteriori** pour refléter des changements ultérieurs du code. Ils capturent l'état au moment de l'implémentation. Les corrections/évolutions se font via de nouvelles propositions.
- **Garder les références croisées valides.** Si une proposition A référence une proposition B par chemin relatif (ex. « voir `normalized_entity_store.md` »), le chemin reste correct après déplacement — utiliser des références par nom de fichier, pas par chemin complet.

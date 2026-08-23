# Images à créer — cartes de rôles

`RoleImage` (lib/widgets/role_image.dart) affiche ces fichiers et retombe
automatiquement sur une icône colorée si le fichier n'existe pas encore :
l'app fonctionne dès maintenant sans aucune image, vous pouvez donc les
ajouter progressivement.

Format recommandé : PNG carré, fond transparent, **512×512 px** minimum
(le widget les recadre en cercle). Un style d'illustration unique pour
toute la série rendra le rendu plus cohérent (par ex. gravure/estampe
façon almanach villageois, dans l'esprit "Thiercelieux").

| Fichier à créer | Rôle | Couleur d'accent (repère de style) |
|---|---|---|
| `assets/images/roles/loup_garou.png` | Loup-Garou | `#A6293B` (rouge sang) |
| `assets/images/roles/voyante.png` | La Voyante | `#6E4B8E` (améthyste) |
| `assets/images/roles/sorciere.png` | La Sorcière | `#6E4B8E` (améthyste) |
| `assets/images/roles/chasseur.png` | Le Chasseur | `#3C6355` (vert forêt) |
| `assets/images/roles/cupidon.png` | Cupidon | `#6E4B8E` (améthyste) |
| `assets/images/roles/petite_fille.png` | La Petite Fille | `#3C6355` (vert forêt) |
| `assets/images/roles/voleur.png` | Le Voleur | `#E8A33D` (ambre lanterne) |
| `assets/images/roles/simple_villageois.png` | Simple Villageois | `#3C6355` (vert forêt) |

## Déclaration dans pubspec.yaml

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/roles/
```

## Suggestions supplémentaires (facultatif)

- `assets/images/app_icon.png` — icône de l'application (1024×1024).
- Une petite illustration de fond pour l'écran d'accueil (lune, forêt).

Aucune de ces images supplémentaires n'est référencée dans le code
actuel — à ajouter seulement si vous personnalisez ces écrans plus tard.
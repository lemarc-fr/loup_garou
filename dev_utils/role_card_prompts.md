# Prompts pour les cartes de rôle manquantes

Rôles sans illustration (`imageAsset` vide ou fichier absent dans
`lib/models/role.dart`) : voleur, bouc émissaire, idiot du village,
salvateur, corbeau, juge bègue, servante dévouée.

Joindre 2 ou 3 cartes existantes (ex : `sorciere.png`, `renard.png`,
`villageois.png`) comme images de référence de style, puis coller le bloc
commun suivi du bloc du rôle.

## Bloc commun (forme, taille, style)

```
Create a role token for a werewolf party game, matching the attached reference images exactly in shape and style.

FORMAT
- Square 512x512 PNG, fully transparent background (alpha), no shadow, no border outside the shape.
- The token fills the canvas edge to edge (about 4 px margin).

SHAPE
- A single flat "pinwheel / shuriken" silhouette with 4 thick curved arms, 4-fold rotational symmetry, arms sweeping counter-clockwise, rounded tips, smooth organic outline (no straight edges, no sharp points).
- The arms carry faint tonal motifs of clawed hands / claw scratches painted in a lighter and darker shade of the main colour, like the references.
- In the centre, a circular medallion (about 55% of the width) outlined by a thin slightly lighter ring, same base colour as the arms.

STYLE
- Hand-painted gouache look: visible brush texture, slight grain, matte, no gradients except soft painterly shading on the arms.
- Naive European folk-art / woodcut illustration, flat stylised figures, limited palette (main colour + black + one or two accents such as ochre yellow, cream, deep green or red).
- The character in the medallion is drawn like a playing-card figure: shown twice, head-to-tail (rotated 180°), so the token reads from any side. Elongated, stylised limbs, simple faces, few details.
- No text, no letters, no numbers, no logo, no frame other than the medallion ring.
- Same lighting, saturation and level of detail as the references; it must look like part of the same set.
```

## Blocs par rôle

**voleur.png** — base colour: dark plum purple.
```
Medallion: a hooded thief with a narrow mask, one hand reaching towards two face-down cards; mirrored head-to-tail. Accents: ochre yellow, cream.
```

**bouc_emissaire.png** — base colour: muddy olive green.
```
Medallion: a sad goat-headed villager with curved horns, tied with a rope, arms hanging; mirrored head-to-tail. Accents: cream, black, dull red.
```

**idiot_du_village.png** — base colour: bright mustard yellow.
```
Medallion: a grinning simpleton in a jester-like cap with bells, holding a wooden spoon, crossed eyes; mirrored head-to-tail. Accents: black, red.
```

**salvateur.png** — base colour: steel blue.
```
Medallion: a robed protector raising a large round shield above a sleeping villager; mirrored head-to-tail. Accents: cream, gold.
```

**corbeau.png** — base colour: deep teal.
```
Medallion: a black raven with spread wings holding a rolled parchment in its beak, a small cross mark on the parchment; mirrored head-to-tail. Accents: black, cream, blood red.
```

**juge_begue.png** — base colour: burgundy red.
```
Medallion: a judge in a black robe and white jabot, raising a gavel, mouth open mid-stutter (small repeated curved lines near the mouth); mirrored head-to-tail. Accents: black, cream, gold.
```

**servante_devouee.png** — base colour: soft sage green.
```
Medallion: a maid in apron and bonnet, kneeling and holding a candle, taking a fallen player's card to her chest; mirrored head-to-tail. Accents: cream, ochre, black.
```

## Après génération

1. Vérifier 512x512, fond transparent (`file` / un éditeur d'image).
2. Copier dans `assets/images/roles/` avec le nom ci-dessus.
3. Renseigner `imageAsset` dans `lib/models/role.dart` (le corbeau pointe
   déjà vers `corbeau.png`).

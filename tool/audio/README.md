# Son de la nuit — générer les fichiers audio

Pendant la nuit, plus personne ne regarde l'écran : le téléphone parle à la
place du meneur de jeu. Il annonce uniquement les moments clés (« La nuit
tombe », « La Voyante se réveille », « La Voyante se rendort », « Le jour se
lève »…), jamais un prénom ni une victime. Une musique d'ambiance tourne en
boucle pendant toute la nuit, et couvre les bruits de ceux qui jouent.

**Aucun fichier n'est obligatoire.** Tant qu'une phrase n'a pas son fichier,
elle est lue par la synthèse vocale du téléphone (dans la langue de l'app).
Sans fichier de musique ou de bruitage, il n'y a simplement pas de musique
ou de bruitage. On peut donc ajouter les fichiers petit à petit.

Les deux sons se coupent dans **Options → Application → Voix du narrateur /
Musique d'ambiance**.

- [Fichiers attendus](#fichiers-attendus)
- [Voix du narrateur : 4 méthodes](#voix-du-narrateur--4-méthodes)
- [Musique d'ambiance et bruitages](#musique-dambiance-et-bruitages)
- [Vérifier](#vérifier)
- [Limites connues](#limites-connues)

Les prompts prêts à copier-coller sont dans [prompts.md](prompts.md).

---

## Fichiers attendus

| Fichier | Contenu | Durée |
|---|---|---|
| `assets/audio/voice/fr/<phrase>.mp3` | les 27 phrases du narrateur en français | 1 à 12 s |
| `assets/audio/voice/en/<phrase>.mp3` | les 27 phrases en anglais | 1 à 12 s |
| `assets/audio/music/night.mp3` | musique de la nuit, jouée en boucle | 2 à 4 min |
| `assets/audio/sfx/nightfall.mp3` | bruitage avant « La nuit tombe » (hurlement de loup) | 2 à 5 s |
| `assets/audio/sfx/daybreak.mp3` | bruitage avant « Le jour se lève » (coq, cloche) | 2 à 5 s |

- **Format** : `.mp3` de préférence (`.m4a` et `.wav` marchent aussi).
  **Pas de `.ogg`** : illisible sur iPhone.
- **Noms** : exactement ceux de la liste, majuscules comprises
  (`wakeVoyante.mp3`, pas `wakevoyante.mp3`).
- Les fichiers sont intégrés à l'app **au moment du build** : après en avoir
  ajouté, relance `flutter run` (un hot reload ne suffit pas).

### La liste des phrases

Les textes vivent dans les fichiers de traduction de l'app
(`lib/l10n/app_fr.arb` et `app_en.arb`, clés `narration…`) : c'est la seule
source, utilisée à la fois par l'app et par le générateur. Pour voir la
liste, avec les fichiers déjà présents :

```sh
dart run tool/audio/generate_voices.dart list
```

| Phrase | Français | English |
|---|---|---|
| `nightFalls` | La nuit tombe sur Thiercelieux. Tout le village s'endort. Fermez les yeux. | Night falls on Thiercelieux… |
| `dayBreaks` | Le jour se lève sur Thiercelieux. Tout le village se réveille. Ouvrez les yeux. | Day breaks over Thiercelieux… |
| `loversReveal` | Les Amoureux vont se découvrir. Le téléphone va faire le tour de la table… | The Lovers will now discover each other… |
| `wake<Rôle>` / `sleep<Rôle>` | « Le Voleur se réveille. » / « Le Voleur se rendort. » | “The Thief wakes up.” / “The Thief goes back to sleep.” |

Rôles concernés (un `wake…` et un `sleep…` chacun) : `Voleur`, `Cupidon`,
`EnfantSauvage`, `Salvateur`, `Voyante`, `Loups`, `LoupBlanc`,
`GrandMechantLoup`, `InfectPereDesLoups`, `Renard`, `Corbeau`, `Sorciere`.

**Changer une phrase** : modifie-la dans le `.arb` (les deux langues), lance
`flutter gen-l10n`, puis régénère seulement son fichier :
`dart run tool/audio/generate_voices.dart piper --lang fr --only wakeVoyante --force …`

**Ajouter une langue** : ajoute `lib/l10n/app_<code>.arb`, le dossier
`assets/audio/voice/<code>/` et sa ligne dans `pubspec.yaml` (section
`assets`).

---

## Voix du narrateur : 4 méthodes

Le script `tool/audio/generate_voices.dart` lit les phrases dans les `.arb`
et écrit directement les fichiers au bon endroit, avec le bon nom. Il
**n'écrase jamais** un fichier existant, sauf avec `--force` : tu peux
mélanger les méthodes (par exemple réenregistrer à la main une seule phrase).

Avec **ffmpeg** installé, le script uniformise aussi le volume de toutes les
phrases (−16 LUFS) et les convertit en mp3 mono. Installe-le d'abord :

| Système | Commande |
|---|---|
| macOS | `brew install ffmpeg` |
| Debian / Ubuntu / Raspberry Pi | `sudo apt install ffmpeg` |
| Windows | `winget install ffmpeg` |

Options utiles pour toutes les méthodes : `--lang fr` (une seule langue),
`--only wakeVoyante,sleepVoyante` (quelques phrases, pratique pour essayer
avant de tout générer), `--force` (refaire), `--reverb` (léger écho de
grande salle).

### A. Piper — gratuit, hors ligne (pour commencer)

[Piper](https://github.com/OHF-Voice/piper1-gpl) tourne sur l'ordinateur, sans
compte ni connexion (testé sur Raspberry Pi 5 : ~2 min pour les 27 phrases).
Qualité correcte, un peu « GPS ».

1. Installe Piper (Python 3.9+) :

   ```sh
   python3 -m venv .venv-piper
   .venv-piper/bin/pip install piper-tts        # Windows : .venv-piper\Scripts\pip install piper-tts
   export PATH="$PWD/.venv-piper/bin:$PATH"      # Windows : $env:Path = "$PWD\.venv-piper\Scripts;" + $env:Path
   ```

2. Télécharge une voix (les **deux** fichiers `.onnx` et `.onnx.json`, côte
   à côte) depuis <https://huggingface.co/rhasspy/piper-voices> :

   | Voix | Langue | Licence | Commentaire |
   |---|---|---|---|
   | `fr_FR-upmc-medium`, locuteur 1 (Pierre) | FR, homme | CC BY-SA 4.0 | testée, recommandée |
   | `fr_FR-siwis-medium` | FR, femme | CC BY 4.0 | |
   | `fr_FR-tom-medium` | FR, homme | AGPL-3.0 | plus naturelle, licence contraignante si l'app est diffusée |
   | `en_GB-northern_english_male-medium` | EN, homme | CC BY-SA 4.0 | testée, recommandée |
   | `en_US-ryan-high` | EN, homme | CC BY-NC-SA 4.0 | interdit en usage commercial |

   ```sh
   mkdir -p voices && cd voices
   base=https://huggingface.co/rhasspy/piper-voices/resolve/main
   curl -LO $base/fr/fr_FR/upmc/medium/fr_FR-upmc-medium.onnx
   curl -LO $base/fr/fr_FR/upmc/medium/fr_FR-upmc-medium.onnx.json
   curl -LO $base/en/en_GB/northern_english_male/medium/en_GB-northern_english_male-medium.onnx
   curl -LO $base/en/en_GB/northern_english_male/medium/en_GB-northern_english_male-medium.onnx.json
   cd ..
   ```

3. Génère :

   ```sh
   dart run tool/audio/generate_voices.dart piper --lang fr --model voices/fr_FR-upmc-medium.onnx --speaker 1
   dart run tool/audio/generate_voices.dart piper --lang en --model voices/en_GB-northern_english_male-medium.onnx
   ```

   `--speed 1.3` ralentit davantage la diction (défaut 1.15 ; 1 = normal).

> Licences CC BY / CC BY-SA : si l'app est publiée, crédite la voix (ex. dans
> la fiche du store : « Voix : UPMC Pierre, CC BY-SA 4.0, via Piper »).

### B. OpenAI — très bonne qualité, quelques centimes

Le modèle `gpt-4o-mini-tts` suit des consignes de jeu d'acteur (« conteur
grave et mystérieux ») : c'est le meilleur rapport qualité / effort. Les 27
phrases × 2 langues coûtent moins de 0,10 $.

1. Crée une clé sur <https://platform.openai.com/api-keys> (il faut un peu
   de crédit sur le compte).
2. Essaie d'abord quelques voix sur deux phrases :

   ```sh
   export OPENAI_API_KEY=sk-...                  # Windows : $env:OPENAI_API_KEY = "sk-..."
   dart run tool/audio/generate_voices.dart openai --lang fr --voice onyx --only nightFalls,wakeVoyante
   ```

   Voix intéressantes pour un narrateur : `onyx` (grave), `ash`, `ballad`,
   `sage`, `verse`. Écoute <https://www.openai.fm> pour comparer. Pour
   refaire avec une autre voix, ajoute `--force`.
3. Génère tout : même commande sans `--only` (et `--lang en` pour l'anglais).

Pour changer le ton : `--instructions "…"` (voir les variantes dans
[prompts.md](prompts.md)).

> Les règles d'OpenAI demandent d'indiquer aux joueurs que la voix est
> générée par une IA (une ligne dans l'écran « À propos » ou la fiche du
> store suffit).

### C. ElevenLabs — la meilleure qualité

Voix les plus naturelles et les plus expressives, en français comme en
anglais.

1. Crée un compte sur <https://elevenlabs.io>. Le plan gratuit (10 000
   caractères/mois) suffit largement (~1 000 caractères par langue), mais il
   impose de créditer ElevenLabs et interdit l'usage commercial ; le plan
   *Starter* lève ces limites.
2. Choisis une voix :
   - **Voice Library** : cherche « narrator », « storyteller », « conteur »,
     filtre par langue, écoute, puis *Add to my voices* ;
   - ou **Voice Design** : décris la voix avec le prompt de
     [prompts.md](prompts.md#1-la-voix-du-narrateur).
3. Copie l'identifiant de la voix (*My Voices* → ⋯ → *Copy voice ID*) et une
   clé d'API (*Developers → API Keys*), puis :

   ```sh
   export ELEVENLABS_API_KEY=...
   dart run tool/audio/generate_voices.dart elevenlabs --lang fr --voice-id <id> --only nightFalls,wakeVoyante
   dart run tool/audio/generate_voices.dart elevenlabs --lang fr --voice-id <id>
   dart run tool/audio/generate_voices.dart elevenlabs --lang en --voice-id <id>
   ```

   Le modèle `eleven_multilingual_v2` (défaut) parle les deux langues avec
   la même voix.

*Sans API* : colle chaque phrase dans l'écran *Text to Speech* du site,
télécharge le mp3 et renomme-le selon la liste (`list`).

### D. Enregistrer une vraie voix

Le plus charmant : la voix d'un ami qui joue habituellement le meneur.

1. Pièce calme et « morte » (rideaux, canapé, pas de carrelage), téléphone
   ou micro à 20 cm de la bouche, mode avion.
2. Lis chaque phrase de la liste (`list`) lentement, d'une voix posée, en
   laissant une seconde de silence entre deux phrases. Refais les ratées.
3. Découpe dans [Audacity](https://www.audacityteam.org) (gratuit) : sélectionne
   une phrase → *Fichier → Exporter la sélection* → mp3, nommée comme dans la
   liste (`wakeVoyante.mp3`…), dans `assets/audio/voice/fr/`.
4. Uniformise le volume de tous les fichiers (macOS / Linux) :

   ```sh
   mkdir -p normalise
   for f in assets/audio/voice/fr/*.mp3; do
     ffmpeg -i "$f" -af "loudnorm=I=-16:TP=-1.5:LRA=11" -ac 1 -codec:a libmp3lame -q:a 4 "normalise/$(basename "$f")"
   done
   mv normalise/*.mp3 assets/audio/voice/fr/
   ```

---

## Musique d'ambiance et bruitages

### Ce qu'il faut

- **Musique** (`assets/audio/music/night.mp3`) : instrumentale, **sans voix,
  sans percussion, sans coup de théâtre**, calme mais inquiétante, 2 à 4
  minutes, qui boucle sans à-coup. Elle est jouée à volume réduit et baisse
  encore pendant chaque phrase du narrateur. Moins de 5 Mo.
- **Bruitages** (facultatifs, 2 à 5 s) : un hurlement de loup lointain
  (`sfx/nightfall.mp3`) et un chant du coq ou une cloche
  (`sfx/daybreak.mp3`). Ils sont coupés avec la musique.

### Où les trouver

| Source | Idéal pour | Licence à vérifier |
|---|---|---|
| [Suno](https://suno.com) / [Udio](https://www.udio.com) | musique sur mesure | plan gratuit = usage non commercial ; plan payant pour publier |
| [ElevenLabs](https://elevenlabs.io) *Music* et *Sound Effects* | musique et bruitages | voir C ci-dessus |
| [Stable Audio](https://stableaudio.com) | ambiance, jusqu'à 3 min | selon le plan |
| [Pixabay Music](https://pixabay.com/music/) / [Pixabay Sound Effects](https://pixabay.com/sound-effects/) | prêt à l'emploi : « dark ambient night », « wolf howl », « rooster » | libre, sans attribution |
| [Freesound](https://freesound.org) | bruitages (filtre *Creative Commons 0*) | CC0 = libre |

Les prompts pour Suno, Udio, ElevenLabs et Stable Audio sont dans
[prompts.md](prompts.md#2-la-musique-de-la-nuit).

### Préparer la musique (boucle sans couture)

Une musique générée finit rarement comme elle commence : le passage de la
fin au début s'entend. Cette commande fond les 6 dernières secondes dans les
6 premières et règle le volume (exemple pour un morceau dont on garde les
180 premières secondes ; adapte `174:180`, `0:6` et `6:174` à
`L-6:L`, `0:6` et `6:L-6`) :

```sh
ffmpeg -i musique_source.mp3 -filter_complex "[0:a]asplit=3[a][b][c];[a]atrim=174:180,asetpts=PTS-STARTPTS[fin];[b]atrim=0:6,asetpts=PTS-STARTPTS[debut];[c]atrim=6:174,asetpts=PTS-STARTPTS[milieu];[fin][debut]acrossfade=d=6[raccord];[raccord][milieu]concat=n=2:v=0:a=1,loudnorm=I=-18:TP=-2:LRA=11[out]" -map "[out]" -ar 44100 -codec:a libmp3lame -q:a 3 assets/audio/music/night.mp3
```

### Préparer un bruitage

Garde 4 secondes, fondu de sortie sur la dernière, volume uniformisé :

```sh
ffmpeg -i hurlement_source.wav -t 4 -af "afade=t=out:st=3:d=1,loudnorm=I=-16:TP=-1.5:LRA=11" -codec:a libmp3lame -q:a 4 assets/audio/sfx/nightfall.mp3
ffmpeg -i coq_source.wav -t 4 -af "afade=t=out:st=3:d=1,loudnorm=I=-16:TP=-1.5:LRA=11" -codec:a libmp3lame -q:a 4 assets/audio/sfx/daybreak.mp3
```

---

## Vérifier

1. `dart run tool/audio/generate_voices.dart list` : chaque phrase doit
   avoir ✅.
2. Relance l'app (`flutter run`, pas de hot reload) et lance une partie
   jusqu'à la nuit. Sur Android, c'est le **volume multimédia** qui compte ;
   sur iPhone, le son passe même en mode silencieux.
3. Pas de son du tout avec la synthèse vocale sur Android ? Vérifie qu'un
   moteur de synthèse vocale est installé et que la voix française est
   téléchargée : *Paramètres → Accessibilité → Synthèse vocale*.

---

## Limites connues

- **Un rôle qui n'est plus appelé s'entend.** Le meneur de l'app n'appelle
  que les rôles qui ont encore quelque chose à faire : quand la Sorcière a
  utilisé ses deux potions, que le Renard a perdu son flair ou que l'Infect
  Père des Loups a infecté, les joueurs remarquent à l'oreille que ce rôle
  n'est plus appelé. Un vrai meneur continue de les appeler « pour rien ».
  Piste d'amélioration : de « faux tours » de quelques secondes.
- **Écran verrouillé.** Si le téléphone se verrouille pendant la nuit, la
  musique s'arrête et reprend au déverrouillage. Garder l'écran allumé
  pendant la partie (paquet `wakelock_plus`) réglerait ce point.

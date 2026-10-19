# Prompts prêts à copier-coller

Pour les fichiers attendus et la marche à suivre, voir [README.md](README.md).

---

## 1. La voix du narrateur

### ElevenLabs — *Voice Design*

Coller dans *Voices → Create a voice → Voice Design*. Le prompt est en
anglais : l'outil le comprend mieux. Générer, écouter les 3 propositions avec
la phrase d'essai, garder la meilleure, puis l'utiliser pour **les deux
langues** (modèle `eleven_multilingual_v2`).

**Narrateur (homme)**

```text
A deep, warm, middle-aged male storyteller with a slightly husky, velvety timbre. He speaks slowly and calmly, with a mysterious, hushed tone, like a village elder telling a tale by the fireside on a dark night in a medieval hamlet. Clear articulation, no exaggerated drama. Studio-quality recording, close microphone, no reverb, no background noise.
```

**Narratrice (femme)**

```text
A low, warm, mature female storyteller with a soft, slightly smoky voice. She speaks slowly and calmly with a mysterious, intimate tone, like a wise woman telling a dark fairy tale by candlelight in a medieval village. Clear articulation, never theatrical. Studio-quality recording, close microphone, no reverb, no background noise.
```

**Phrase d'essai** (champ *Text to preview*) :

```text
La nuit tombe sur Thiercelieux. Tout le village s'endort. Fermez les yeux. La Voyante se réveille.
```

Réglages conseillés une fois la voix choisie : *Stability* 55–65 %,
*Similarity* 75–80 %, *Style* 10–20 % (au-delà, la voix surjoue).

### OpenAI — `gpt-4o-mini-tts` (option `--instructions`)

Le script utilise déjà la consigne « conteur grave », adaptée à la langue.
Variantes à passer avec `--instructions "…"` :

**Conteur au coin du feu (défaut, version française)**

```text
Voice: a deep, warm storyteller — the game master of a Werewolf party game, speaking at night to players who have their eyes closed.
Tone: calm, mysterious, slightly hushed, never theatrical or cartoonish.
Pacing: slow and steady, with a short pause after each sentence.
Pronunciation: native French from France, articulate every word clearly.
```

**Plus sombre, presque chuchoté**

```text
Voice: low, breathy, close to a whisper, as if not to wake the wolves.
Tone: ominous and tense, with restrained menace.
Pacing: very slow, leave a silence after each sentence.
Pronunciation: native French from France.
```

**Crieur public médiéval (plus vivant)**

```text
Voice: a seasoned medieval town crier with a rich, resonant voice.
Tone: solemn and grand, but warm; slightly playful when announcing who wakes up.
Pacing: measured, with dramatic pauses before the role's name.
Pronunciation: native French from France.
```

Pour l'anglais, remplacer la dernière ligne par
`Pronunciation: native British English.`

### Enregistrement humain — consignes au lecteur

> Tu es le meneur de jeu d'une partie de Loup-Garou, la nuit. Les joueurs
> ont les yeux fermés et n'ont que ta voix pour se repérer. Parle lentement,
> d'une voix grave et posée, un peu feutrée, sans en faire trop. Marque une
> courte pause à chaque point. Laisse une seconde de silence avant et après
> chaque phrase. Si tu butes, recommence la phrase entière.

---

## 2. La musique de la nuit

Contraintes communes, à garder en tête quel que soit l'outil : **instrumental,
pas de percussion, pas de montée ni de coup de théâtre, volume constant, pas
de mélodie trop accrocheuse** (on l'entend en boucle pendant toute la nuit),
2 à 4 minutes. Générer 3 ou 4 versions et garder la plus « plate ».

### Suno

Activer *Instrumental*, puis dans *Style of Music* :

```text
dark medieval ambient, slow, mysterious, calm, soft drones, distant low cello, gentle hurdy-gurdy, sparse wooden flute, night forest atmosphere, crickets, wind in the trees, no drums, no percussion, no vocals, steady dynamics, 60 bpm, loopable
```

Titre : `Nuit sur Thiercelieux`.

### Udio

```text
Instrumental dark folk ambient for the night phase of a werewolf board game. Soft low drones, sparse nylon guitar and cello, distant owl, wind through pine trees, crickets. Calm but suspenseful, steady volume, no percussion, no vocals, no climax.
```

### ElevenLabs — *Music*

```text
A 3-minute instrumental dark ambient track for the night phase of a werewolf party game played around a table. Calm, mysterious and slightly ominous: low sustained cello drones, soft hurdy-gurdy, a sparse wooden flute motif, wind in the trees and faint crickets. No drums, no vocals, no build-up, no sudden sounds, constant volume from start to finish. Start and end on the same sustained drone so it loops seamlessly.
```

### Stable Audio

Durée : 180 s.

```text
Dark medieval ambient soundscape, low cello drone, soft hurdy-gurdy, wind, distant owl hoots, crickets, mysterious, calm, steady, no percussion, no vocals, 60 BPM, loopable
```

### Banques libres de droits (sans générer)

Mots-clés à chercher sur Pixabay Music ou YouTube Audio Library :
`dark ambient night`, `medieval ambient`, `mysterious forest`,
`dark fantasy ambience`, `horror ambient calm`.

---

## 3. Les bruitages (facultatifs)

### ElevenLabs — *Sound Effects* (durée 4 s, *Prompt influence* ~50 %)

**`sfx/howl.mp3`** (au réveil des Loups-Garous)

```text
A single distant wolf howl echoing over a misty forest at night, soft wind in the trees, no music
```

**`sfx/daybreak.mp3`** (au choix)

```text
A rooster crowing once at dawn in a quiet medieval village, a few birds chirping in the distance, no music
```

```text
A single church bell tolling once at dawn over a small village, gentle morning birds, no music
```

### Freesound (filtre *Creative Commons 0*)

Rechercher `wolf howl distant`, `rooster crow`, `church bell single`.
Puis couper à 4 s avec la commande de la section « Préparer un bruitage » du
[README](README.md#préparer-un-bruitage).

import 'dart:typed_data';

/// Durée d'un fichier MP3, en additionnant la durée de chacune de ses
/// trames : exacte en débit fixe comme en débit variable, sans plugin audio.
/// Null si [bytes] ne contient aucune trame MPEG audio.
Duration? mp3Duration(Uint8List bytes) {
  var offset = _skipId3v2(bytes);
  var micros = 0.0;
  var frames = 0;

  while (offset + 4 <= bytes.length) {
    final frame = _MpegFrame.parse(bytes, offset);
    if (frame == null) {
      offset++; // octets parasites (balise ID3v1 en fin de fichier...)
      continue;
    }
    micros += frame.samples * 1e6 / frame.sampleRate;
    frames++;
    offset += frame.length;
  }
  return frames == 0 ? null : Duration(microseconds: micros.round());
}

/// Taille de la balise ID3v2 en tête de fichier (0 s'il n'y en a pas).
int _skipId3v2(Uint8List b) {
  if (b.length < 10 || b[0] != 0x49 || b[1] != 0x44 || b[2] != 0x33) return 0;
  // Taille « synchsafe » : 7 bits utiles par octet.
  final size = (b[6] & 0x7f) << 21 |
      (b[7] & 0x7f) << 14 |
      (b[8] & 0x7f) << 7 |
      (b[9] & 0x7f);
  final hasFooter = b[5] & 0x10 != 0;
  return 10 + size + (hasFooter ? 10 : 0);
}

class _MpegFrame {
  final int length;
  final int samples;
  final int sampleRate;

  const _MpegFrame(this.length, this.samples, this.sampleRate);

  // Débits en kbit/s, selon la version MPEG et la couche.
  static const _bitratesV1 = [
    [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448],
    [0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384],
    [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320],
  ];
  static const _bitratesV2 = [
    [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256],
    [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
    [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
  ];
  static const _sampleRatesV1 = [44100, 48000, 32000];

  static _MpegFrame? parse(Uint8List b, int i) {
    // Mot de synchronisation : 11 bits à 1.
    if (b[i] != 0xff || b[i + 1] & 0xe0 != 0xe0) return null;
    final version = (b[i + 1] >> 3) & 0x3; // 0 : 2.5, 2 : 2, 3 : 1
    final layerBits = (b[i + 1] >> 1) & 0x3; // 3 : I, 2 : II, 1 : III
    final bitrateIndex = b[i + 2] >> 4;
    final sampleRateIndex = (b[i + 2] >> 2) & 0x3;
    final padding = (b[i + 2] >> 1) & 0x1;
    if (version == 1 ||
        layerBits == 0 ||
        bitrateIndex == 0 ||
        bitrateIndex == 15 ||
        sampleRateIndex == 3) {
      return null;
    }
    final layer = 4 - layerBits; // 1, 2 ou 3
    final mpeg1 = version == 3;
    final bitrate =
        (mpeg1 ? _bitratesV1 : _bitratesV2)[layer - 1][bitrateIndex] * 1000;
    final sampleRate = _sampleRatesV1[sampleRateIndex] ~/
        switch (version) {
          3 => 1,
          2 => 2,
          _ => 4,
        };
    final samples = switch (layer) {
      1 => 384,
      2 => 1152,
      _ => mpeg1 ? 1152 : 576,
    };
    final length = layer == 1
        ? (12 * bitrate ~/ sampleRate + padding) * 4
        : samples ~/ 8 * bitrate ~/ sampleRate + padding;
    if (length < 4) return null;
    return _MpegFrame(length, samples, sampleRate);
  }
}

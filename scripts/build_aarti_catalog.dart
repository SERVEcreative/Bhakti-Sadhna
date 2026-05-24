// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Dev-only: searches YouTube and writes verified video IDs to aarti_audio.json.
Future<void> main() async {
  final queries = <String, String>{
    'jai_ganesh': 'जय गणेश जय गणेश देवा आरती',
    'shiv_aarti': 'ओम जय शिव ओंकारा आरती',
    'vishnu_aarti': 'ओम जय जगदीश हरे आरती',
    'lakshmi_aarti': 'ओम जय लक्ष्मी माता आरती',
    'hanuman_aarti': 'आरती कीजै हनुमान लला की',
    'durga_aarti': 'जय अम्बे गौरी आरती',
    'krishna_aarti': 'आरती कुंजबिहारी की',
    'ram_aarti': 'श्री रामचंद्र कृपालु भजु आरती',
    'saraswati_aarti': 'जय सरस्वती माता आरती',
    'kali_aarti': 'जय काली माता आरती',
    'sai_aarti': 'ओम साईं राम आरती',
    'shani_aarti': 'जय जय शनि देव आरती',
    'surya_aarti': 'जय काष्ठ हेलो सूर्य आरती',
    'skanda_aarti': 'जय स्कन्दमाता आरती',
    'radha_aarti': 'जय राधे माधव आरती',
    'parvati_aarti': 'जय गौरी माता आरती',
    'jagannath_aarti': 'जय जगन्नाथ स्वामी आरती',
    'balaji_aarti': 'श्री वेंकटेश्वर गोविन्दा आरती',
    'narasimha_aarti': 'जय नृसिंह देव आरती',
    'gayatri_aarti': 'जय गायत्री माता आरती',
    'annapurna_aarti': 'जय अन्नपूर्णा माता आरती',
    'ganga_aarti': 'हर हर गंगे आरती',
    'satya_aarti': 'जय लक्ष्मी रमणा सत्यनारायण आरती',
    'kubera_aarti': 'जय धनाध्यक्ष कुबेर आरती',
  };

  final yt = YoutubeExplode();
  final sources = <String, Map<String, String>>{};

  for (final entry in queries.entries) {
    final id = entry.key;
    final query = entry.value;
    try {
      final results = await yt.search.search(query, filter: TypeFilters.video);
      Video? picked;
      for (final v in results.take(8)) {
        try {
          await yt.videos.streamsClient.getManifest(v.id);
          picked = v;
          break;
        } catch (_) {
          continue;
        }
      }
      if (picked == null) {
        print('$id: no playable result');
        continue;
      }
      sources[id] = {'youtubeVideoId': picked.id.value};
      print('$id → ${picked.id.value} (${picked.title})');
      await Future<void>.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      print('$id error: $e');
    }
  }

  yt.close();

  final out = {
    'version': 1,
    'sources': sources,
  };
  final path = 'assets/content/aarti_audio.json';
  await File(path).writeAsString(const JsonEncoder.withIndent('  ').convert(out));
  print('Wrote $path (${sources.length} entries)');
}

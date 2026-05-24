import 'package:bhakti_sadhana/services/katha_tts/katha_tts_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('splits sentences with pauses', () {
    const raw = 'राजा ने कहा, पुत्र मिलेगा। वे खुश हुए।';
    final segs = KathaTtsText.segmentsFromParagraph(raw, 0);
    expect(segs.length, greaterThanOrEqualTo(2));
    expect(segs.first.text, isNot(contains(',')));
    expect(segs.first.text, isNot(contains('।')));
    expect(segs.first.pauseAfter.inMilliseconds, lessThan(120));
    expect(segs.last.pauseAfter.inMilliseconds, lessThan(280));
  });

  test('cleanClause removes punctuation names', () {
    final t = KathaTtsText.cleanClause('हे भक्तिन! दूर्वा, लड्डू।');
    expect(t.contains('!'), isFalse);
    expect(t.contains(','), isFalse);
    expect(t, contains('हे भक्तिन'));
  });
}

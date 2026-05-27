import 'package:bhakti_sadhana/data/models/donation_cause.dart';
import 'package:flutter/material.dart';

/// दान विकल्प — वर्तमान में तीन श्रेणियाँ।
abstract final class DonationCatalog {
  static const List<DonationCause> all = [
    DonationCause(
      id: 'gau_daan',
      group: DonationGroup.general,
      title: 'गौ दान',
      taglineHi: 'गौ माता की सेवा — पुण्य का मार्ग',
      description:
          'आपका दान गौशाला में चारा, चिकित्सा और आश्रय के लिए लगता है। शास्त्रों में गौ दान अत्यंत पुण्यदायी माना गया है।',
      icon: Icons.pets_rounded,
    ),
    DonationCause(
      id: 'temple_trust',
      group: DonationGroup.general,
      title: 'मंदिर ट्रस्ट',
      taglineHi: 'दीप, भोग और मंदिर सेवा',
      description:
          'मंदिर में दीपक, भोग, सफाई और धार्मिक कार्यों हेतु। आपकी श्रद्धा सीधे मंदिर सेवा में समर्पित होती है।',
      icon: Icons.temple_hindu_rounded,
    ),
    DonationCause(
      id: 'app_development',
      group: DonationGroup.general,
      title: 'ऐप विकास टीम',
      taglineHi: 'भक्ति ऐप को और बेहतर बनाएँ',
      description:
          'नई आरती, कथा, मंदिर अनुभव और बिना रुकावट ऐप — ताकि लाखों भक्त घर बैठे साधना कर सकें।',
      icon: Icons.volunteer_activism_rounded,
    ),
  ];

  static DonationCause? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<DonationCause> forGroup(DonationGroup group) {
    return all.where((c) => c.group == group).toList();
  }
}

import 'package:bhakti_sadhana/data/models/donation_cause.dart';
import 'package:flutter/material.dart';

/// दान विकल्प — वर्तमान में तीन श्रेणियाँ।
abstract final class DonationCatalog {
  static const List<DonationCause> all = [
    DonationCause(
      id: 'gau_daan',
      group: DonationGroup.general,
      title: 'गौ दान',
      description: 'गौशाला, चारा, आश्रय और गौ रक्षा के लिए दान।',
      icon: Icons.pets_rounded,
    ),
    DonationCause(
      id: 'temple_trust',
      group: DonationGroup.general,
      title: 'मंदिर ट्रस्ट',
      description: 'मंदिर निर्माण, दीप, भोग और धार्मिक कार्यों के लिए।',
      icon: Icons.temple_hindu_rounded,
    ),
    DonationCause(
      id: 'app_development',
      group: DonationGroup.general,
      title: 'ऐप विकास टीम',
      description: 'नई सुविधाएँ और ऐप बेहतर बनाने के लिए डेवलपर टीम सहायता।',
      icon: Icons.code_rounded,
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

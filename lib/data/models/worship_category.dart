import 'package:flutter/material.dart';

enum WorshipCategory {
  puja(
    'puja',
    'पूजा विधि',
    'घर की पूजा',
    Icons.volunteer_activism_rounded,
    'assets/images/categories/puja.png',
  ),
  aarti(
    'aarti',
    'आरती स्तुति',
    'दीप आरती',
    Icons.local_fire_department_rounded,
    'assets/images/categories/aarti.png',
  ),
  mantra(
    'mantra',
    'मंत्र',
    'पवित्र जप',
    Icons.auto_awesome_rounded,
    'assets/images/categories/mantra.png',
  ),
  festival(
    'festival',
    'त्योहार',
    'पर्व विधि',
    Icons.celebration_rounded,
    'assets/images/categories/festival.png',
  ),
  vrat(
    'vrat',
    'व्रत कथा',
    'उपवास कथा',
    Icons.nights_stay_rounded,
    'assets/images/categories/vrat.png',
  ),
  donation(
    'donation',
    'दान पुण्य',
    'सेवा और दान',
    Icons.volunteer_activism_rounded,
    'assets/images/categories/donation.png',
  );

  const WorshipCategory(
    this.id,
    this.label,
    this.subtitle,
    this.icon,
    this.imageAsset,
  );

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;

  /// PNG path — [AppAssetImage] se load hota hai.
  final String imageAsset;

  static WorshipCategory? fromId(String id) {
    for (final c in WorshipCategory.values) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// देवता चयन नहीं — सीधे दान स्क्रीन।
  bool get opensDonationScreen => this == WorshipCategory.donation;
}

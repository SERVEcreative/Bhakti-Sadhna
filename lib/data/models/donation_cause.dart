import 'package:flutter/material.dart';

enum DonationGroup {
  general('general', 'दान का उद्देश्य चुनें', 'गौ दान, मंदिर ट्रस्ट या ऐप विकास');

  const DonationGroup(this.id, this.title, this.subtitle);

  final String id;
  final String title;
  final String subtitle;
}

class DonationCause {
  const DonationCause({
    required this.id,
    required this.group,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final DonationGroup group;
  final String title;
  final String description;
  final IconData icon;
}

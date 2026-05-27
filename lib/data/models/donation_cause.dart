import 'package:flutter/material.dart';

enum DonationGroup {
  general(
    'general',
    'किस कार्य में योगदान दें?',
    'जिस सेवा से हृदय प्रसन्न हो, वहीं से शुरू करें — हर दान पुण्य है',
  );

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
    required this.taglineHi,
    required this.description,
    required this.icon,
  });

  final String id;
  final DonationGroup group;
  final String title;
  /// कार्ड पर छोटी प्रेरक पंक्ति।
  final String taglineHi;
  final String description;
  final IconData icon;
}

import 'package:flutter/material.dart';

enum DonationGroup {
  seva('seva', 'सेवा दान', 'गौ, माता-पिता और समाज सेवा'),
  mandir('mandir', 'मंदिर सेवा', 'दीप, भोग और मंदिर निर्माण'),
  teerth('teerth', 'तीर्थ और देश', 'भारत व विदेश के पवित्र स्थान');

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

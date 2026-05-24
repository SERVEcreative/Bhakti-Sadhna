import 'package:bhakti_sadhana/data/models/donation_cause.dart';
import 'package:flutter/material.dart';

/// सभी दान श्रेणियाँ — होम और दान स्क्रीन।
abstract final class DonationCatalog {
  static const List<DonationCause> all = [
  // —— सेवा ——
  DonationCause(
    id: 'gau_seva',
    group: DonationGroup.seva,
    title: 'गौ सेवा',
    description: 'गौशाला, चारा, आश्रय और गौ रक्षा।',
    icon: Icons.pets_rounded,
  ),
  DonationCause(
    id: 'matru_seva',
    group: DonationGroup.seva,
    title: 'मातृ सेवा',
    description: 'माताओं, बालिकाओं और महिला सेवा केंद्र।',
    icon: Icons.favorite_rounded,
  ),
  DonationCause(
    id: 'pitru_seva',
    group: DonationGroup.seva,
    title: 'पितृ सेवा',
    description: 'पितरों की श्राद्ध, तर्पण और पूजा सामग्री।',
    icon: Icons.water_drop_rounded,
  ),
  DonationCause(
    id: 'annadaan',
    group: DonationGroup.seva,
    title: 'अन्नदान',
    description: 'मंदिर व आश्रम में भोजन व प्रसाद।',
    icon: Icons.restaurant_rounded,
  ),
  DonationCause(
    id: 'vidyadaan',
    group: DonationGroup.seva,
    title: 'विद्यादान',
    description: 'गुरुकुल, पुस्तकें और गरीब छात्र सहायता।',
    icon: Icons.menu_book_rounded,
  ),
  DonationCause(
    id: 'rogi_seva',
    group: DonationGroup.seva,
    title: 'रोगी सेवा',
    description: 'अस्पताल सहायता और दवा दान।',
    icon: Icons.medical_services_outlined,
  ),
  DonationCause(
    id: 'vriksha_seva',
    group: DonationGroup.seva,
    title: 'वृक्ष सेवा',
    description: 'वृक्षारोपण और पर्यावरण संरक्षण।',
    icon: Icons.park_rounded,
  ),
  // —— मंदिर ——
  DonationCause(
    id: 'mandir_nirman',
    group: DonationGroup.mandir,
    title: 'मंदिर निर्माण',
    description: 'नए मंदिर, जीर्णोद्धार और शिखर निर्माण।',
    icon: Icons.temple_hindu_rounded,
  ),
  DonationCause(
    id: 'mandir_diya',
    group: DonationGroup.mandir,
    title: 'दीप दान',
    description: 'दीप, तेल और दैनिक आरती व्यवस्था।',
    icon: Icons.local_fire_department_rounded,
  ),
  DonationCause(
    id: 'mandir_bhog',
    group: DonationGroup.mandir,
    title: 'भोग व अर्चना',
    description: 'फल, फूल, भोग और पूजा सामग्री।',
    icon: Icons.inventory_2_outlined,
  ),
  DonationCause(
    id: 'mandir_gau_shala',
    group: DonationGroup.mandir,
    title: 'मंदिर गौशाला',
    description: 'मंदिर से जुड़ी गौ सेवा और संरक्षण।',
    icon: Icons.house_rounded,
  ),
  DonationCause(
    id: 'mandir_annual',
    group: DonationGroup.mandir,
    title: 'वार्षिक उत्सव',
    description: 'जयंती, रथ यात्रा और त्योहार व्यवस्था।',
    icon: Icons.celebration_rounded,
  ),
  // —— तीर्थ / देश ——
  DonationCause(
    id: 'ayodhya',
    group: DonationGroup.teerth,
    title: 'अयोध्या राम मंदिर',
    description: 'श्री राम जन्मभूमि मंदिर सेवा।',
    icon: Icons.account_balance_rounded,
  ),
  DonationCause(
    id: 'kashi',
    group: DonationGroup.teerth,
    title: 'काशी विश्वनाथ',
    description: 'काशी कॉरिडोर और घाट सेवा।',
    icon: Icons.landscape_rounded,
  ),
  DonationCause(
    id: 'haridwar',
    group: DonationGroup.teerth,
    title: 'हरिद्वार गंगा',
    description: 'हर की पौड़ी और गंगा आरती सेवा।',
    icon: Icons.waves_rounded,
  ),
  DonationCause(
    id: 'kedarnath',
    group: DonationGroup.teerth,
    title: 'केदारनाथ / चारधाम',
    description: 'हिमालयी धाम सेवा और यात्री सुविधा।',
    icon: Icons.terrain_rounded,
  ),
  DonationCause(
    id: 'vaishno_devi',
    group: DonationGroup.teerth,
    title: 'वैष्णो देवी',
    description: 'माता वैष्णो देवी मंदिर सेवा।',
    icon: Icons.hiking_rounded,
  ),
  DonationCause(
    id: 'tirupati',
    group: DonationGroup.teerth,
    title: 'तिरुपति बालाजी',
    description: 'श्री वेंकटेश्वर स्वामी सेवा।',
    icon: Icons.star_rounded,
  ),
  DonationCause(
    id: 'puri_jagannath',
    group: DonationGroup.teerth,
    title: 'पुरी जगन्नाथ',
    description: 'जगन्नाथ मंदिर महाप्रसाद सेवा।',
    icon: Icons.temple_buddhist_rounded,
  ),
  DonationCause(
    id: 'somnath',
    group: DonationGroup.teerth,
    title: 'सोमनाथ',
    description: 'प्रथम ज्योतिर्लिंग सोमनाथ सेवा।',
    icon: Icons.brightness_high_rounded,
  ),
  DonationCause(
    id: 'dwarka',
    group: DonationGroup.teerth,
    title: 'द्वारका',
    description: 'श्री कृष्ण द्वारकाधीश सेवा।',
    icon: Icons.sailing_rounded,
  ),
  DonationCause(
    id: 'nepal_pashupati',
    group: DonationGroup.teerth,
    title: 'नेपाल पशुपतिनाथ',
    description: 'काठमांडू पशुपतिनाथ मंदिर सेवा।',
    icon: Icons.flag_rounded,
  ),
  DonationCause(
    id: 'bali_hindu',
    group: DonationGroup.teerth,
    title: 'बाली (इंडोनेशिया)',
    description: 'बाली के प्राचीन हिंदू मंदिर संरक्षण।',
    icon: Icons.beach_access_rounded,
  ),
  DonationCause(
    id: 'mauritius_ganga',
    group: DonationGroup.teerth,
    title: 'मॉरीशस गंगा तालाब',
    description: 'विदेश में पवित्र तीर्थ सेवा।',
    icon: Icons.water_rounded,
  ),
  DonationCause(
    id: 'usa_mandir',
    group: DonationGroup.teerth,
    title: 'अमेरिका हिंदू मंदिर',
    description: 'USA में हिंदू समुदाय मंदिर सहायता।',
    icon: Icons.public_rounded,
  ),
  DonationCause(
    id: 'uk_mandir',
    group: DonationGroup.teerth,
    title: 'यूके हिंदू मंदिर',
    description: 'ब्रिटेन में मंदिर निर्माण सहायता।',
    icon: Icons.language_rounded,
  ),
  DonationCause(
    id: 'canada_mandir',
    group: DonationGroup.teerth,
    title: 'कनाडा हिंदू मंदिर',
    description: 'कनाडा में धार्मिक केंद्र सेवा।',
    icon: Icons.map_rounded,
  ),
  DonationCause(
    id: 'fiji_mandir',
    group: DonationGroup.teerth,
    title: 'फ़िजी / दक्षिण प्रशांत',
    description: 'दक्षिण प्रशांत द्वीपों के हिंदू मंदिर।',
    icon: Icons.wb_sunny_outlined,
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

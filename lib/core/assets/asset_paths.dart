/// Saari app images PNG — path helper.
abstract final class AssetPaths {
  static const String pngExtension = 'png';

  static String deityImage(String id) => 'assets/images/deities/$id.png';

  static const String mandirTempleArch = 'assets/images/mandir/temple_arch.png';

  static const String mandirPujaThali = 'assets/images/mandir/puja_thali.png';
  static const String mandirGendaPhool = 'assets/images/mandir/genda_phool.png';
  static const String mandirShankha = 'assets/images/mandir/shankh.png';
  /// Purane bundles / rename se pehle wala naam.
  static const String mandirShankhaLegacy = 'assets/images/mandir/shankha.png';
  static const String mandirCarpet = 'assets/images/mandir/carpet.png';

  static const String mandirAartiSound = 'assets/sounds/mandir_aarti.mp3';
  /// शंख बटन / carpet शंख / आरती के बीच — घंटी (`temple_bell`) नहीं।
  static const String mandirShankhSound = 'assets/sounds/mandir_shankh.mp3';

  /// `puja.png` / `puja.jpg` / `.../puja` → `.../puja`
  static String stripExtension(String path) {
    return path.replaceFirst(
      RegExp(r'\.(png|jpe?g|webp)$', caseSensitive: false),
      '',
    );
  }

  static String toPngPath(String pathOrBase) => '${stripExtension(pathOrBase)}.png';
}

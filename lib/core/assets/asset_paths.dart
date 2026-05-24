/// Saari app images PNG — path helper.
abstract final class AssetPaths {
  static const String pngExtension = 'png';

  static String deityImage(String id) => 'assets/images/deities/$id.png';

  static String categoryImage(String id) => 'assets/images/categories/$id.png';

  /// `puja.png` / `puja.jpg` / `.../puja` → `.../puja`
  static String stripExtension(String path) {
    return path.replaceFirst(
      RegExp(r'\.(png|jpe?g|webp)$', caseSensitive: false),
      '',
    );
  }

  static String toPngPath(String pathOrBase) => '${stripExtension(pathOrBase)}.png';
}

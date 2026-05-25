/// Product imagery — bundled SVG + optional JPEG (see scripts/download_product_images.ps1).
class MarketplaceAssets {
  MarketplaceAssets._();

  static const String _base = 'assets/images/products';

  static const String promoBackToSchool = '$_base/promo_back_to_school.svg';

  static const String schoolStarterKit = '$_base/school_starter_kit.svg';
  static const String classicPoloUniform = '$_base/classic_polo_uniform.svg';
  static const String stemActivityPack = '$_base/stem_activity_pack.svg';
  static const String vitaminGummies = '$_base/vitamin_gummies.svg';
  static const String readingAdventureSet = '$_base/reading_adventure_set.svg';
  static const String artCraftBox = '$_base/art_craft_box.svg';

  /// Unsplash (free) — used when bundled JPEG is not present yet.
  static const String urlSchoolStarterKit =
      'https://images.unsplash.com/photo-1588072432836-e345f2c79d54?w=480&q=80';
  static const String urlClassicPoloUniform =
      'https://images.unsplash.com/photo-1519238263530-7522f504fee8?w=480&q=80';
  static const String urlStemActivityPack =
      'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=480&q=80';
  static const String urlVitaminGummies =
      'https://images.unsplash.com/photo-1550572017-edd226bffa55?w=480&q=80';
  static const String urlReadingAdventureSet =
      'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=480&q=80';
  static const String urlArtCraftBox =
      'https://images.unsplash.com/photo-1513364776144-60967b33f800?w=480&q=80';
  static const String urlPromoBackToSchool =
      'https://images.unsplash.com/photo-1503676260728-1c00da280a02?w=720&q=80';

  static String jpegPath(String svgAssetPath) =>
      svgAssetPath.replaceAll('.svg', '.jpg');
}

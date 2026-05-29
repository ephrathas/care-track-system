import 'image_sources.dart';

/// Product imagery — bundled SVG + optional JPEG (see tool/download_assets.dart).
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

  static const String urlSchoolStarterKit = ImageSources.schoolStarterKit;
  static const String urlClassicPoloUniform = ImageSources.classicPoloUniform;
  static const String urlStemActivityPack = ImageSources.stemActivityPack;
  static const String urlVitaminGummies = ImageSources.vitaminGummies;
  static const String urlReadingAdventureSet = ImageSources.readingAdventureSet;
  static const String urlArtCraftBox = ImageSources.artCraftBox;
  static const String urlPromoBackToSchool = ImageSources.promoBackToSchool;

  static String jpegPath(String svgAssetPath) =>
      svgAssetPath.replaceAll('.svg', '.jpg');
}

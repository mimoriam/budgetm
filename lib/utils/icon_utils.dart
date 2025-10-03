import 'package:hugeicons/hugeicons.dart';

/// Utility to map icon identifier strings (from category initializer) to
/// HugeIcons objects. The HugeIcons type used in the project is a
/// List<List<dynamic>>, so this function returns that type.
List<List<dynamic>> getIcon(String? iconId) {
  switch (iconId) {
    // Expense icons
    case 'icon_supermarket':
      return HugeIcons.strokeRoundedShoppingBag01;
    case 'icon_clothing':
      return HugeIcons.strokeRoundedShirt01;
    case 'icon_house':
      return HugeIcons.strokeRoundedHome07;
    case 'icon_transport':
      return HugeIcons.strokeRoundedCar05;
    case 'icon_entertainment':
      return HugeIcons.strokeRoundedMusicNote03;
    case 'icon_gifts':
      return HugeIcons.strokeRoundedGift;
    case 'icon_travel':
      return HugeIcons.strokeRoundedShoppingBag01;
    case 'icon_education':
      return HugeIcons.strokeRoundedBook03;
    case 'icon_food':
      return HugeIcons.strokeRoundedServingFood;
    case 'icon_work':
      return HugeIcons.strokeRoundedWork;
    case 'icon_electronics':
      return HugeIcons.strokeRoundedSendToMobile02;
    case 'icon_sport':
      return HugeIcons.strokeRoundedWorkoutSport;
    case 'icon_restaurant':
      return HugeIcons.strokeRoundedRestaurant;
    case 'icon_health':
      return HugeIcons.strokeRoundedHeartCheck;
    case 'icon_communications':
      return HugeIcons.strokeRoundedBubbleChat;
    case 'icon_others_expense':
      return HugeIcons.strokeRoundedMoreHorizontal;

    // Income icons
    case 'icon_salary':
      return HugeIcons.strokeRoundedWallet01;
    case 'icon_income':
      return HugeIcons.strokeRoundedDollarSend01;
    case 'icon_rewards':
      return HugeIcons.strokeRoundedStar;
    case 'icon_gifts_income':
      return HugeIcons.strokeRoundedGift;
    case 'icon_business':
      return HugeIcons.strokeRoundedBriefcaseDollar;
    case 'icon_others_income':
      return HugeIcons.strokeRoundedMoreHorizontal;

    // Defaults used in initializer
    case 'icon_default_expense':
      return HugeIcons.strokeRoundedShoppingBag01;
    case 'icon_default_income':
      return HugeIcons.strokeRoundedBitcoin02;

    // Fallback default
    default:
      return HugeIcons.strokeRoundedShoppingBag01;
  }
}
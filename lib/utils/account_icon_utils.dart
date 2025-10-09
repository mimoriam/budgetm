// Utility for account icons mapping
import 'package:hugeicons/hugeicons.dart';

/// Returns a List<List<dynamic>> containing the corresponding HugeIcons object
/// for the given accountType. Defaults to Cash icon when null or unknown.
List<List<dynamic>> getAccountIcon(String? accountType) {
  switch (accountType) {
    case 'Cash':
      return [
        [HugeIcons.strokeRoundedCash01]
      ];
    case 'Master Card':
      return [
        [HugeIcons.strokeRoundedCreditCard]
      ];
    case 'Wallet':
      return [
        [HugeIcons.strokeRoundedWallet01]
      ];
    case 'Cryptocurrency':
      return [
        [HugeIcons.strokeRoundedBitcoin]
      ];
    case 'Saving':
      return [
        [HugeIcons.strokeRoundedPiggyBank]
      ];
    case 'Gold':
      return [
        [HugeIcons.strokeRoundedGold]
      ];
    case 'Safe':
      return [
        [HugeIcons.strokeRoundedSafe]
      ];
    case 'Bank':
      return [
        [HugeIcons.strokeRoundedBank]
      ];
    case 'Investment':
      return [
        [HugeIcons.strokeRoundedIdVerified]
      ];
    default:
      return [
        [HugeIcons.strokeRoundedCash01]
      ];
  }
}
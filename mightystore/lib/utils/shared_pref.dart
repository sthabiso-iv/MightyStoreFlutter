import 'package:nb_utils/nb_utils.dart';

import 'constants.dart';

Future<bool> isLoggedIn() async {
  return await getBool(IS_LOGGED_IN) ?? false;
}
Future<bool> isGuestUser() async {
  return await getBool(IS_GUEST_USER) ?? false;
}
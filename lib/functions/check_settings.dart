import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> checkSettings(String? event) async {
  event = event?.toLowerCase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  switch (event) {
    case 'goal':
      return prefs.getBool('Goals') ?? true;

    case 'var':
      return prefs.getBool('var') ?? true;

    case 'card':
      return prefs.getBool('Red cards') ?? true;

    case 'subst':
      return prefs.getBool('Substitution') ?? true;
    case 'ht':
      return prefs.getBool('Half time') ?? true;
    case 'ft':
      return prefs.getBool('Full time') ?? true;
    // case 'pen':
    //   return  prefs.getBool('Missed penalty') ?? true;
    case 'et':
      return prefs.getBool('Extra time') ?? true;
    case '15_min':
      return prefs.getBool('15_min') ?? true;
    case 'lineup':
      return prefs.getBool('Lineup') ?? true;
    case 'ms':
      return prefs.getBool('Match Started') ?? true;
    case 'fifteen':
      return prefs.getBool('15_min') ?? true;
    case 'all':
      return prefs.getBool('all') ?? true;

    default:
      return true;
  }
}

import '../../localization/demo_localization.dart';

String matchStatusReturner(String matchStat, String time, int? elapsed) {
  // if (elapsed != null &&  !["FT", "PST", "AET", "CANC", "ABD", "AWD", "TBD" , "NS" ,  "WO" , "PEN"].contains(matchStat)) {
  //   return "${elapsed.toString()}'";
  // }
  String value;

  switch (matchStat) {
    case 'NS':
      // value = "አልተጀመረም";
      value = time;
    case 'TBD':
      value = DemoLocalizations.notDecided;
      //  "አልተወሰነም";
      break;

    case '1H':
      value = DemoLocalizations.firstHalf;
      break;

    case 'HT':
      value = DemoLocalizations.breakTime;
      break;

    case '2H':
      value = DemoLocalizations.secondHalf;
      break;

    case 'ET':
      value = DemoLocalizations.extraTime;
      break;

    case 'BT':
      value = DemoLocalizations.breakTimeExtraTime;
      break;

    case 'P':
      value = DemoLocalizations.penality;
      break;

    case 'SUSP':
      value = DemoLocalizations.suspended;
      break;

    case 'INT':
      value = DemoLocalizations.matchInterrupted;
      break;

    case 'FT':
      value = DemoLocalizations.finished;
      break;

    case 'AET':
      value = DemoLocalizations.finishedExtraTime;
      break;

    case 'PEN':
      value = DemoLocalizations.finishedByPenality;
      break;

    case 'PST':
      value = DemoLocalizations.postponed;
      break;

    case 'CANC':
      value = DemoLocalizations.cancelled;
      break;

    case 'ABD':
      value = DemoLocalizations.abandoned;
      break;

    case 'AWD':
      value = DemoLocalizations.technicalLoss;
      break;

    case 'WO':
      value = DemoLocalizations.walkOver;
      break;

    case 'LIVE':
      value = DemoLocalizations.live;
      break;

    default:
      value = matchStat;
  }
  return value;
}

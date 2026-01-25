import '../localization/demo_localization.dart';

String translateType(String? eventDetail) {
  eventDetail = eventDetail?.toLowerCase();
  switch (eventDetail) {
    case 'goal':
      return DemoLocalizations.goalEvent;

    case 'var':
      return DemoLocalizations.varEvent;

    case 'card':
      return DemoLocalizations.redCard;

    case 'subst':
      return DemoLocalizations.subst;

    case 'bt':
      return DemoLocalizations.breakTime;
    case '2h':
      return DemoLocalizations.secondHalf;
    case 'ft':
      return DemoLocalizations.matchEnded;
    case 'fifteen':
      return DemoLocalizations.fifteenMinutesLeft;
    case 'pen':
      return DemoLocalizations.penality;
    case 'ms':
      return DemoLocalizations.matchStarted;
    case 'lineup':
      return DemoLocalizations.lineUp;
    case 'red card':
      return '🟥 ${DemoLocalizations.redCard}';
    case 'yellow card':
      return '🟨 ${DemoLocalizations.yellowCard}';
    case 'podcast':
      return DemoLocalizations.listen;

    default:
      return eventDetail ?? '';
  }
}

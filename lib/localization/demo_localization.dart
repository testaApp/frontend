import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';
import '../main.dart';
import '../util/add_to_hive.dart';

class DemoLocalizations {
  DemoLocalizations();

  static final Box<LocalizationData> _box =
      Hive.box<LocalizationData>('localization');

  static List<dynamic>? get languages =>
      _box.keys.map((key) => key.split('-').first).toSet().toList();

  static String get language {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-language');
    return localizationData?.value ?? '';
  }

  static String getLocalizedValue(String languageCode, String key) {
    final localizationData = _box.get('$languageCode-$key');
    return localizationData?.value ?? '';
  }

  static String get week {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-week');
    return localizationData?.value ?? 'Week';
  }

  static String get groupStage {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-groupStage');
    return localizationData?.value ?? 'Group Stage';
  }

  static String get leg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leg');
    return localizationData?.value ?? 'Leg';
  }

  static String get qualifying {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-qualifying');
    return localizationData?.value ?? 'Qualifying';
  }

  static String get playOff {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-playOff');
    return localizationData?.value ?? 'Play-off';
  }
// === Statistics Getters ===

  static String get cleanSheet {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_clean_sheet');
    return localizationData?.value ?? '';
  }

  static String get head2head {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-head2head');
    return localizationData?.value ?? 'Head to Head';
  }

  static String get notification_title {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notification_title');
    return localizationData?.value ?? 'Never miss the action';
  }

  static String get notification_body {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notification_body');
    return localizationData?.value ??
        'Live scores, breaking news, match highlights, and new podcasts — right when it happens.';
  }

  static String get notification_enable {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notification_enable');
    return localizationData?.value ?? 'Turn on notifications';
  }

  static String get notification_not_now {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notification_not_now');
    return localizationData?.value ?? 'Not now';
  }

  static String get no_h2h_found {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-no_h2h_found');
    return localizationData?.value ?? 'No Head-to-Head matches found';
  }

  static String get penalty_cancelled {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penalty_cancelled');
    return localizationData?.value ?? '';
  }

  static String get off_the_ball_foul {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-off_the_ball_foul');
    return localizationData?.value ?? '';
  }

  static String get spitting {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-spitting');
    return localizationData?.value ?? '';
  }

  static String get biting {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-biting');
    return localizationData?.value ?? '';
  }

  static String get elbowing {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-elbowing');
    return localizationData?.value ?? '';
  }

  static String get pleaseWait {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-please_wait');
    return localizationData?.value ?? 'Please wait...';
  }

  static String get abusive_language {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-abusive_language');
    return localizationData?.value ?? '';
  }

  static String get retaliation {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-retaliation');
    return localizationData?.value ?? '';
  }

  static String get offside {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-offside');
    return localizationData?.value ?? '';
  }

  static String get dangerous_play {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dangerous_play');
    return localizationData?.value ?? '';
  }

  static String get obstruction {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-obstruction');
    return localizationData?.value ?? '';
  }

  static String get var_review {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-var_review');
    return localizationData?.value ?? '';
  }

  static String get unsportsmanlike_conduct {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-unsportsmanlike_conduct');
    return localizationData?.value ?? '';
  }

  static String get penalty_awarded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penalty_awarded');
    return localizationData?.value ?? '';
  }

  static String get goal_disallowed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal_disallowed');
    return localizationData?.value ?? '';
  }

  static String get professional_foul_last_man {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-professional_foul_last_man');
    return localizationData?.value ?? '';
  }

  static String get holding {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-holding');
    return localizationData?.value ?? '';
  }

  static String get failedToScore {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_failed_to_score');
    return localizationData?.value ?? '';
  }

  static String get goalkeeperSaves {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goalkeeper_saves');
    return localizationData?.value ?? '';
  }

  static String get longestStreak {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_longest_streak');
    return localizationData?.value ?? '';
  }

  static String get winStreak {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_win_streak');
    return localizationData?.value ?? '';
  }

  static String get drawStreak {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_draw_streak');
    return localizationData?.value ?? '';
  }

  static String get loseStreak {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_lose_streak');
    return localizationData?.value ?? '';
  }

  static String get biggestWin {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_biggest_win');
    return localizationData?.value ?? '';
  }

  static String get biggestLoss {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_biggest_loss');
    return localizationData?.value ?? '';
  }

  static String get mostGoalsScoredMatch {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-stats_most_goals_scored_match');
    return localizationData?.value ?? '';
  }

  static String get mostGoalsConcededMatch {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-stats_most_goals_conceded_match');
    return localizationData?.value ?? '';
  }

  static String get penaltiesTaken {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_penalties_taken');
    return localizationData?.value ?? '';
  }

  static String get mostUsedFormation {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-stats_most_used_formation');
    return localizationData?.value ?? '';
  }

  static String get timesPlayed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_times_played');
    return localizationData?.value ?? '';
  }

  static String get goalsByMinute {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_goals_by_minute');
    return localizationData?.value ?? '';
  }

  static String get goalsConceded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_goals_conceded');
    return localizationData?.value ?? '';
  }

  static String get avgGoalsConceded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stats_avg_goals_conceded');
    return localizationData?.value ?? '';
  }

  static String get homepage {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-homepage');
    return localizationData?.value ?? '';
  }

  static String get seasonPerformance {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-seasonPerformance');
    return localizationData?.value ?? '';
  }

  static String get change_photo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-change_photo');
    return localizationData?.value ?? '';
  }

  static String get profile {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-profile');
    return localizationData?.value ?? '';
  }

  static String get verifying {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-verifying');
    return localizationData?.value ?? '';
  }

  static String get verify {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-verify');
    return localizationData?.value ?? '';
  }

  static String get cancel {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cancel');
    return localizationData?.value ?? '';
  }

  static String get verify_phone_first {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-verify_phone_first');
    return localizationData?.value ?? '';
  }

  static String get profile_update_success {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-profile_update_success');
    return localizationData?.value ?? '';
  }

  static String get update_profile_error {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-update_profile_error');
    return localizationData?.value ?? '';
  }

  static String get save_changes {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-save_changes');
    return localizationData?.value ?? '';
  }

  static String get logout {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-logout');
    return localizationData?.value ?? '';
  }

  static String get userAdded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-userAdded');
    return localizationData?.value ?? '';
  }

  static String get afternoon {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-afternoon');
    return localizationData?.value ?? '';
  }

  static String get startingSoon {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-startingSoon');
    return localizationData?.value ?? '';
  }

  static String get dusk {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dusk');
    return localizationData?.value ?? '';
  }

  static String get dawn {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dusk');
    return localizationData?.value ?? '';
  }

  static String get penaltyShootout {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penaltyShootout');
    return localizationData?.value ?? '';
  }

  static String get penaltyInProgress {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penaltyInProgress');
    return localizationData?.value ?? '';
  }

  static String get matchInterrupted {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-matchInterrupted');
    return localizationData?.value ?? '';
  }

  static String get afterExtraTime {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-afterExtraTime');
    return localizationData?.value ?? '';
  }

  static String get notificationPermissionRequired {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-notificationPermissionRequired');
    return localizationData?.value ?? '';
  }

  static String get transferWindowDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-transferWindowDesc');
    return localizationData?.value ?? '';
  }

  static String get notificationsDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notificationsDesc');
    return localizationData?.value ?? '';
  }

  static String get dailyQuizDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dailyQuizDesc');
    return localizationData?.value ?? '';
  }

  static String get savedNewsDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-savedNewsDesc');
    return localizationData?.value ?? '';
  }

  static String get testaMarketDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-testaMarketDesc');
    return localizationData?.value ?? '';
  }

  static String get settingsDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-settingsDesc');
    return localizationData?.value ?? '';
  }

  static String get shareAppDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-shareAppDesc');
    return localizationData?.value ?? '';
  }

  static String get aboutUsDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-aboutUsDesc');
    return localizationData?.value ?? '';
  }

  static String get rateUsDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-rateUsDesc');
    return localizationData?.value ?? '';
  }

  static String get contactUsDesc {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-contactUsDesc');
    return localizationData?.value ?? '';
  }

  static String get enterLiveTvUrl {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enterLiveTvUrl');
    return localizationData?.value ?? '';
  }

  static String get tvShows {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tvShows');
    return localizationData?.value ?? '';
  }

  static String get timeLeft {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-timeLeft');
    return localizationData?.value ?? '';
  }

  static String get question {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-question');
    return localizationData?.value ?? '';
  }

  static String get dailyQuizChallenge {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dailyQuizChallenge');
    return localizationData?.value ?? '';
  }

  static String get trueText {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-true');
    return localizationData?.value ?? '';
  }

  static String get enterYourAnswer {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enter_your_answer');
    return localizationData?.value ?? '';
  }

  static String get seconds {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-seconds');
    return localizationData?.value ?? '';
  }

  static String get daily_quiz_completed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-daily_quiz_completed');
    return localizationData?.value ?? '';
  }

  static String get falseText {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-false');
    return localizationData?.value ?? '';
  }

  static String get viewLeaderboard {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-viewLeaderboard');
    return localizationData?.value ?? '';
  }

  static String get saved_news {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saved_news');
    return localizationData?.value ?? '';
  }

  static String get TV {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-TV');
    return localizationData?.value ?? '';
  }

  static String get freeTrialEndingSoon {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-freeTrialEndingSoon');
    return localizationData?.value ?? '';
  }

  static String get predict_the_score {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-predict_the_score');
    return localizationData?.value ?? '';
  }

  static String get submit_prediction {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-submit_prediction');
    return localizationData?.value ?? '';
  }

  static String get error_loading_predictions {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-error_loading_predictions');
    return localizationData?.value ?? '';
  }

  static String get prediction_stats {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-prediction_stats');
    return localizationData?.value ?? '';
  }

  static String get your_prediction {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-your_prediction');
    return localizationData?.value ?? '';
  }

  static String get select_plan_to_continue {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-select_plan_to_continue');
    return localizationData?.value ?? '';
  }

  static String get read_them_here {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-read_them_here');
    return localizationData?.value ?? '';
  }

  static String get terms_conditions_agreement {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-terms_conditions_agreement');
    return localizationData?.value ?? '';
  }

  static String get popular {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-popular');
    return localizationData?.value ?? '';
  }

  static String get freeTrialEndingSoonMessage {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-freeTrialEndingSoonMessage');
    return localizationData?.value ?? '';
  }

  static String get payment_successful {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-payment_successful');
    return localizationData?.value ?? '';
  }

  static String get fromCard {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fromCard');
    return localizationData?.value ?? '';
  }

  static String get freeTrialEnded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-freeTrialEnded');
    return localizationData?.value ?? '';
  }

  static String get freeTrialEndedMessage {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-freeTrialEndedMessage');
    return localizationData?.value ?? '';
  }

  static String get subscriptionExpired {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-subscriptionExpired');
    return localizationData?.value ?? '';
  }

  static String get subscriptionExpiredMessage {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-subscriptionExpiredMessage');
    return localizationData?.value ?? '';
  }

  static String get subscriptionEndingSoon {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-subscriptionEndingSoon');
    return localizationData?.value ?? '';
  }

  static String get canRequestNewCode {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-can_request_new_code');
    return localizationData?.value ?? '';
  }

  static String get subscriptionEndingSoonMessage {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-subscriptionEndingSoonMessage');
    return localizationData?.value ?? '';
  }

  static String get subscriptionActive {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-subscriptionActive');
    return localizationData?.value ?? '';
  }

  static String get subscriptionActiveMessage {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-subscriptionActiveMessage');
    return localizationData?.value ?? '';
  }

  static String get Subscribe {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-Subscribe');
    return localizationData?.value ?? '';
  }

  // Choose Your Subscription
  static String get chooseYourSubscription {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-chooseYourSubscription');
    return localizationData?.value ?? '';
  }

  // New localizations
  static String get subscriptionUpdatedSuccessfully {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-subscriptionUpdatedSuccessfully');
    return localizationData?.value ?? '';
  }

  static String get subscriptionUpdateFailed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-subscriptionUpdateFailed');
    return localizationData?.value ?? '';
  }

  static String get error {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-error');
    return localizationData?.value ?? '';
  }

  static String get noSubscriptionPlansAvailable {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-noSubscriptionPlansAvailable');
    return localizationData?.value ?? '';
  }

  // Select a subscription plan
  static String get selectSubscriptionPlan {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-selectSubscriptionPlan');
    return localizationData?.value ?? '';
  }

// selectPaymentMethod
  static String get selectPaymentMethod {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-selectPaymentMethod');
    return localizationData?.value ?? '';
  }

// telebirr
  static String get telebirr {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-telebirr');
    return localizationData?.value ?? '';
  }

// chapaPayments
  static String get chapaPayments {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-chapaPayments');
    return localizationData?.value ?? '';
  }

// creditDebitCard
  static String get creditDebitCard {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-creditDebitCard');
    return localizationData?.value ?? '';
  }

// verifyAndPay
  static String get verifyAndPay {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-verifyAndPay');
    return localizationData?.value ?? '';
  }

// enterOTP
  static String get enterOTP {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enterOTP');
    return localizationData?.value ?? '';
  }

// getOTP
  static String get getOTP {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-getOTP');
    return localizationData?.value ?? '';
  }

// telebirrPayment
  static String get telebirrPayment {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-telebirrPayment');
    return localizationData?.value ?? '';
  }

  // money
  static String get money {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-money');
    return localizationData?.value ?? '';
  }

  // Continue
  static String get continueText {
    // Use 'continueText' to avoid conflict with the Dart 'continue' keyword
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-continue');
    return localizationData?.value ?? '';
  }

  // Best Value
  static String get bestValue {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bestValue');
    return localizationData?.value ?? '';
  }

  // Year
  static String get year {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-year');
    return localizationData?.value ?? '';
  }

  // Month
  static String get month {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-month');
    return localizationData?.value ?? '';
  }

  // Months
  static String get months {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-months');
    return localizationData?.value ?? '';
  }

  // Daily Pass
  static String get dailyPass {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dailyPass');
    return localizationData?.value ?? '';
  }

  static String get dismiss {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dismiss');
    return localizationData?.value ?? '';
  }

  static String get socialmediatitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-socialmediatitle');
    return localizationData?.value ?? '';
  }

  static String get loadingPlayers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-loadingPlayers');
    return localizationData?.value ?? '';
  }

  static String get socialmediabody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-socialmediabody');
    return localizationData?.value ?? '';
  }

  static String get allownotificationtitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-allownotificationtitle');
    return localizationData?.value ?? '';
  }

  static String get allownotificationbody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-allownotificationbody');
    return localizationData?.value ?? '';
  }

  static String get notificationTitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notificationTitle');
    return localizationData?.value ?? '';
  }

  static String get notificationBody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notificationBody');
    return localizationData?.value ?? '';
  }

  static String get your_favourite_player {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-your_favourite_player');
    return localizationData?.value ?? '';
  }

  static String get choose_your_fav_player {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-choose_your_fav_player');
    return localizationData?.value ?? '';
  }

  static String get searchByName {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-searchByName');
    return localizationData?.value ?? '';
  }

  static String get players {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-players');
    return localizationData?.value ?? '';
  }

  static String get selected {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-selected');
    return localizationData?.value ?? '';
  }

  static String get networkProblem {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-networkProblem');
    return localizationData?.value ?? '';
  }

  static String get tryAgain {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tryAgain');
    return localizationData?.value ?? '';
  }

  static String get favouriteTeam {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-favouriteTeam');
    return localizationData?.value ?? '';
  }

  static String get pressTheStar {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-pressTheStar');
    return localizationData?.value ?? '';
  }

  static String get teamSelected {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-teamSelected');
    return localizationData?.value ?? '';
  }

  static String get ethiopia {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ethiopia');
    return localizationData?.value ?? '';
  }

  static String get england {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-england');
    return localizationData?.value ?? '';
  }

  static String get spain {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-spain');
    return localizationData?.value ?? '';
  }

  static String get italy {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-italy');
    return localizationData?.value ?? '';
  }

  static String get germany {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-germany');
    return localizationData?.value ?? '';
  }

  static String get france {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-france');
    return localizationData?.value ?? '';
  }

  static String get saudi {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saudi');
    return localizationData?.value ?? '';
  }

  static String get turkey {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-turkey');
    return localizationData?.value ?? '';
  }

  static String get southAfrica {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-southAfrica');
    return localizationData?.value ?? '';
  }

  static String get egypt {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-egypt');
    return localizationData?.value ?? '';
  }

  static String get usa {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-usa');
    return localizationData?.value ?? '';
  }

  static String get netherland {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-netherland');
    return localizationData?.value ?? '';
  }

  static String get belgium {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-belgium');
    return localizationData?.value ?? '';
  }

  static String get portugal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-portugal');
    return localizationData?.value ?? '';
  }

  static String get scotland {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-scotland');
    return localizationData?.value ?? '';
  }

  static String get qatar {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-qatar');
    return localizationData?.value ?? '';
  }

  static String get networkproblem {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-networkproblem');
    return localizationData?.value ?? '';
  }

  static String get tryagain {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tryagain');
    return localizationData?.value ?? '';
  }

  static String get welcome {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-welcome');
    return localizationData?.value ?? '';
  }

  static String get welcomebody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-welcomebody');
    return localizationData?.value ?? '';
  }

  static String get soccerWearTitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-soccerWearTitle');
    return localizationData?.value ?? '';
  }

  static String get soccerWearBody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-soccerWearBody');
    return localizationData?.value ?? '';
  }

  static String get videoHighlightsTitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-videoHighlightsTitle');
    return localizationData?.value ?? '';
  }

  static String get videoHighlightsBody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-videoHighlightsBody');
    return localizationData?.value ?? '';
  }

  static String get News_intro_Title {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-News_intro_Title');
    return localizationData?.value ?? '';
  }

  static String get News_intro_body {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-News_intro_body');
    return localizationData?.value ?? '';
  }

  static String get stayAheadTitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stayAheadTitle');
    return localizationData?.value ?? '';
  }

  static String get stayAheadBody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stayAheadBody');
    return localizationData?.value ?? '';
  }

  static String get leaguesListTitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leaguesListTitle');
    return localizationData?.value ?? '';
  }

  static String get leaguesListBody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leaguesListBody');
    return localizationData?.value ?? '';
  }

  static String get podcastsTitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-podcastsTitle');
    return localizationData?.value ?? '';
  }

  static String get podcastsBody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-podcastsBody');
    return localizationData?.value ?? '';
  }

  static String get nextButton {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-nextButton');
    return localizationData?.value ?? '';
  }

  static String get clubstitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-clubstitle');
    return localizationData?.value ?? '';
  }

  static String get clubsbody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-clubsbody');
    return localizationData?.value ?? '';
  }

  static String get leaguestitle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leaguestitle');
    return localizationData?.value ?? '';
  }

  static String get leaguesbody {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leaguesbody');
    return localizationData?.value ?? '';
  }

  static String get settings {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-settings');
    return localizationData?.value ?? '';
  }

  static String get Try_testa_App_for_14_days_for_free {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-Try_testa_App_for_14_days_for_free');
    return localizationData?.value ?? '';
  }

  static String get clean_sheet {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-clean_sheet');
    return localizationData?.value ?? '';
  }

  static String get saved {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saved');
    return localizationData?.value ?? '';
  }

  static String get goals_ontarget {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goals on target');
    return localizationData?.value ?? '';
  }

  static String get shots {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-shots');
    return localizationData?.value ?? '';
  }

  static String get headed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-headed');
    return localizationData?.value ?? '';
  }

  static String get clearance {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-clearance');
    return localizationData?.value ?? '';
  }

  static String get goalkeeper {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goalkeeper');
    return localizationData?.value ?? '';
  }

  static String get centerBack {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-centerBack');
    return localizationData?.value ?? '';
  }

  static String get rightBack {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-rightBack');
    return localizationData?.value ?? '';
  }

  static String get leftBack {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leftBack');
    return localizationData?.value ?? '';
  }

  static String get sweeper {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sweeper');
    return localizationData?.value ?? '';
  }

  static String get defensiveMidfielder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-defensiveMidfielder');
    return localizationData?.value ?? '';
  }

  static String get centralMidfielder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-centralMidfielder');
    return localizationData?.value ?? '';
  }

  static String get rightMidfielder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-rightMidfielder');
    return localizationData?.value ?? '';
  }

  static String get leftMidfielder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leftMidfielder');
    return localizationData?.value ?? '';
  }

  static String get kg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-kg');
    return localizationData?.value ?? '';
  }

  static String get country {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-country');
    return localizationData?.value ?? '';
  }

  static String get squad {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-squad');
    return localizationData?.value ?? '';
  }

  static String get teamSquadNotFound {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-team_squad_not_found');
    return localizationData?.value ?? 'Team squad not found';
  }

  static String get total {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total');
    return localizationData?.value ?? '';
  }

  static String get centimeter {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-centimeter');
    return localizationData?.value ?? '';
  }

  static String get attackingMidfielder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-attackingMidfielder');
    return localizationData?.value ?? '';
  }

  static String get wingerForward {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wingerForward');
    return localizationData?.value ?? '';
  }

  static String get secondStriker {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-secondStriker');
    return localizationData?.value ?? '';
  }

  static String get centerForward {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-centerForward');
    return localizationData?.value ?? '';
  }

  static String get woodwork {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-woodwork');
    return localizationData?.value ?? '';
  }

  static String get position {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-position');
    return localizationData?.value ?? '';
  }

  static String get nationality {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-nationality');
    return localizationData?.value ?? '';
  }

  static String get crosses {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-crosses');
    return localizationData?.value ?? '';
  }

  static String get punches {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-punches');
    return localizationData?.value ?? '';
  }

  static String get goal_conceded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal conceded');
    return localizationData?.value ?? '';
  }

  static String get Through_Balls {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-Through Balls');
    return localizationData?.value ?? '';
  }

  static String get fouls {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fouls');
    return localizationData?.value ?? '';
  }

  static String get Turkey {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-Turkey');
    return localizationData?.value ?? '';
  }

  static String get promotion {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-promotion');
    return localizationData?.value ?? '';
  }

  static String get promotion_qualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-promotion_qualification');
    return localizationData?.value ?? '';
  }

  static String get morning {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-morning');
    return localizationData?.value ?? '';
  }

  static String get AFCqualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-AFCqualification');
    return localizationData?.value ?? '';
  }

  static String get europaleaguequalification {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-europaleague_qualification');
    return localizationData?.value ?? '';
  }

  static String get evening {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-evening');
    return localizationData?.value ?? '';
  }

  static String get USA {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-USA');
    return localizationData?.value ?? '';
  }

  static String get last_5_in {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-last_5_in');
    return localizationData?.value ?? '';
  }

  static String get video_not_found {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-video_not_found');
    return localizationData?.value ?? '';
  }

  static String get stat_info {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stat_info');
    return localizationData?.value ?? '';
  }

  static String get MLS {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-MLS');
    return localizationData?.value ?? '';
  }

  static String get dark {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dark');
    return localizationData?.value ?? '';
  }

  static String get light {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-light');
    return localizationData?.value ?? '';
  }

  static String get win {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-win');
    return localizationData?.value ?? '';
  }

  static String get olympicsmen {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-olympicsmen');
    return localizationData?.value ?? '';
  }

  static String get no_favorite_player {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-no_favorite_player');
    return localizationData?.value ?? '';
  }

  static String get no_favorite_team {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-no_favorite_team');
    return localizationData?.value ?? '';
  }

  static String get loss {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-loss');
    return localizationData?.value ?? '';
  }

  static String get title {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-title');
    return localizationData?.value ?? '';
  }

  static String get transfer_window {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-transfer_window');
    return localizationData?.value ?? '';
  }

  static String get description {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-description');
    return localizationData?.value ?? '';
  }

  static String get ongoing {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ongoing');
    return localizationData?.value ?? '';
  }

  static String get completed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-completed');
    return localizationData?.value ?? '';
  }

  static String get next_matchs {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-next_matchs');
    return localizationData?.value ?? '';
  }

  static String get close {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-close');
    return localizationData?.value ?? '';
  }

  static String get result {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-result');
    return localizationData?.value ?? '';
  }

  static String get describing {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-describing');
    return localizationData?.value ?? '';
  }

  static String get found {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-found');
    return localizationData?.value ?? '';
  }

  static String get capacity {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-capacity');
    return localizationData?.value ?? '';
  }

  static String get surface {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-surface');
    return localizationData?.value ?? '';
  }

  static String get tournaments {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tournaments');
    return localizationData?.value ?? '';
  }

  static String get venue {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-venue');
    return localizationData?.value ?? '';
  }

  static String get recentNews {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-recent_news');
    return localizationData?.value ?? '';
  }

  static String get recentMatches {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-recent_matches');
    return localizationData?.value ?? '';
  }

  static String get forYou {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-for_you');
    return localizationData?.value ?? '';
  }

  static String get whatsNew {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-whats_new');
    return localizationData?.value ?? '';
  }

  static String get transfer {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-transfer');
    return localizationData?.value ?? '';
  }

  static String get trendingNews {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-trending_news');
    return localizationData?.value ?? '';
  }

  static String get news {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-news');
    return localizationData?.value ?? '';
  }

  static String get leagues {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leagues');
    return localizationData?.value ?? '';
  }

  static String get games {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-games');
    return localizationData?.value ?? '';
  }

  static String get favourite {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-favourite');
    return localizationData?.value ?? '';
  }

  static String get listen {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-listen');
    return localizationData?.value ?? '';
  }

  static String get table {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-table');
    return localizationData?.value ?? '';
  }

  static String get knock_out {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-knock_out');
    return localizationData?.value ?? '';
  }

  static String get news_singular {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-news_singular');
    return localizationData?.value ?? '';
  }

  static String get team_statistics {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-team_statistics');
    return localizationData?.value ?? '';
  }

  static String get player_statistics {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-player_statistics');
    return localizationData?.value ?? '';
  }

  static String get seasons {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-seasons');
    return localizationData?.value ?? '';
  }

  static String get short {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-short');
    return localizationData?.value ?? '';
  }

  static String get full {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-full');
    return localizationData?.value ?? '';
  }

  static String get strength {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-strength');
    return localizationData?.value ?? '';
  }

  static String get overall {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-overall');
    return localizationData?.value ?? '';
  }

  static String get home {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-home');
    return localizationData?.value ?? '';
  }

  static String get away {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-away');
    return localizationData?.value ?? '';
  }

  static String get theme {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-theme');
    return localizationData?.value ?? '';
  }

  static String get languageSetting {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-language');
    return localizationData?.value ?? '';
  }

  static String get notification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notification');
    return localizationData?.value ?? '';
  }

  static String get testaMarket {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-testa_market');
    return localizationData?.value ?? '';
  }

  static String get shareApp {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-share_app');
    return localizationData?.value ?? '';
  }

  static String get aboutUs {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-about_us');
    return localizationData?.value ?? '';
  }

  static String get rateUs {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-rate_us');
    return localizationData?.value ?? '';
  }

  static String get followUs {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-follow_us');
    return localizationData?.value ?? '';
  }

  static String get contactUs {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-contact_us');
    return localizationData?.value ?? '';
  }

  static String get trendingView {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-trending_view');
    return localizationData?.value ?? '';
  }

  static String get january {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-january');
    return localizationData?.value ?? '';
  }

  static String get february {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-february');
    return localizationData?.value ?? '';
  }

  static String get march {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-march');
    return localizationData?.value ?? '';
  }

  static String get april {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-april');
    return localizationData?.value ?? '';
  }

  static String get may {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-may');
    return localizationData?.value ?? '';
  }

  static String get june {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-june');
    return localizationData?.value ?? '';
  }

  static String get july {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-july');
    return localizationData?.value ?? '';
  }

  static String get august {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-august');
    return localizationData?.value ?? '';
  }

  static String get september {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-september');
    return localizationData?.value ?? '';
  }

  static String get october {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-october');
    return localizationData?.value ?? '';
  }

  static String get november {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-november');
    return localizationData?.value ?? '';
  }

  static String get december {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-december');
    return localizationData?.value ?? '';
  }

  static String get pagume {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-pagume');
    return localizationData?.value ?? '';
  }

  static String get monday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-monday');
    return localizationData?.value ?? '';
  }

  static String get tuesday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tuesday');
    return localizationData?.value ?? '';
  }

  static String get wednesday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wednesday');
    return localizationData?.value ?? '';
  }

  static String get thursday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-thursday');
    return localizationData?.value ?? '';
  }

  static String get friday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-friday');
    return localizationData?.value ?? '';
  }

  static String get saturday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saturday');
    return localizationData?.value ?? '';
  }

  static String get sunday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sunday');
    return localizationData?.value ?? '';
  }

  static String get highlight {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-highlight');
    return localizationData?.value ?? '';
  }

  static String get listenNews {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-listen_news');
    return localizationData?.value ?? '';
  }

  static String get status {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-status');
    return localizationData?.value ?? '';
  }

  static String get rank {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-rank');
    return localizationData?.value ?? '';
  }

  static String get teamName {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-teamName');
    return localizationData?.value ?? '';
  }

  static String get played {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-played');
    return localizationData?.value ?? '';
  }

  static String get goal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal');
    return localizationData?.value ?? '';
  }

  static String get point {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-point');
    return localizationData?.value ?? '';
  }

  static String get won {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-won');
    return localizationData?.value ?? '';
  }

  static String get draw {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-draw');
    return localizationData?.value ?? '';
  }

  static String get lost {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-lost');
    return localizationData?.value ?? '';
  }

  static String get premierLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-premier_league');
    return localizationData?.value ?? '';
  }

  static String get championsLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-champions_league');
    return localizationData?.value ?? '';
  }

  static String get ethiopianPremierLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ethiopian_premier_league');
    return localizationData?.value ?? '';
  }

  static String get laLiga {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-la_liga');
    return localizationData?.value ?? '';
  }

  static String get ligue1 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ligue_1');
    return localizationData?.value ?? '';
  }

  static String get press_the_star {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-press_the_star');
    return localizationData?.value ?? '';
  }

  static String get serieA {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-serie_a');
    return localizationData?.value ?? '';
  }

  static String get bundesliga {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bundesliga');
    return localizationData?.value ?? '';
  }

  static String get europaLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-europa_league');
    return localizationData?.value ?? '';
  }

  static String get saudiProLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saudi_pro_league');
    return localizationData?.value ?? '';
  }

  static String get faCup {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fa_cup');
    return localizationData?.value ?? '';
  }

  static String get carabaoEFL {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-carabao_efl');
    return localizationData?.value ?? '';
  }

  static String get carabaoEFLShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-carabao_short');
    return localizationData?.value ?? '';
  }

  static String get averageGoals {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-average_goals');
    return localizationData?.value ?? '';
  }

  static String get leastConceded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-least_conceded');
    return localizationData?.value ?? '';
  }

  static String get topScorer {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-top_scorer');
    return localizationData?.value ?? '';
  }

  static String get previousMatchLineup {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-previousMatchLineup');
    return localizationData?.value ?? '';
  }

  static String get topAssist {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-top_assist');
    return localizationData?.value ?? '';
  }

  static String get topYellowCards {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-top_yellow_cards');
    return localizationData?.value ?? '';
  }

  static String get champion {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-champion');
    return localizationData?.value ?? '';
  }

  static String get second {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-second');
    return localizationData?.value ?? '';
  }

  static String get all {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-all');
    return localizationData?.value ?? '';
  }

  static String get premierLeagueShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-premier_league_short');
    return localizationData?.value ?? '';
  }

  static String get championsLeagueShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-champions_league_short');
    return localizationData?.value ?? '';
  }

  static String get spainLaligaShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-spain_laliga_short');
    return localizationData?.value ?? '';
  }

  static String get italySerieAShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-italy_serie_a_short');
    return localizationData?.value ?? '';
  }

  static String get bundesLigaShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bundes_liga_short');
    return localizationData?.value ?? '';
  }

  static String get ethiopianPremierLeagueShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-ethiopian_premier_league_short');
    return localizationData?.value ?? '';
  }

  static String get franceLeague1Short {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-france_league_1_short');
    return localizationData?.value ?? '';
  }

  static String get saudiProLeagueShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saudi_pro_league_short');
    return localizationData?.value ?? '';
  }

  static String get faCupShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fa_cup_short');
    return localizationData?.value ?? '';
  }

  static String get Friendlies {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-Friendlies');
    return localizationData?.value ?? '';
  }

  static String get day {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-day');
    return localizationData?.value ?? '';
  }

  static String get night {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-night');
    return localizationData?.value ?? '';
  }

  static String get Read_more_at {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-Read_more_at');
    return localizationData?.value ?? '';
  }

  static String get today {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-today');
    return localizationData?.value ?? '';
  }

  static String get yesterday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-yesterday');
    return localizationData?.value ?? '';
  }

  static String get tomorrow {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tomorrow');
    return localizationData?.value ?? '';
  }

  static String get otherMatches {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-other_matches');
    return localizationData?.value ?? '';
  }

  static String get notDecided {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-not_decided');
    return localizationData?.value ?? '';
  }

  static String get firstHalf {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-first_half');
    return localizationData?.value ?? '';
  }

  static String get breakTime {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-break_time');
    return localizationData?.value ?? '';
  }

  static String get secondHalf {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-second_half');
    return localizationData?.value ?? '';
  }

  static String get extraTime {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-extra_time');
    return localizationData?.value ?? '';
  }

  static String get breakTimeExtraTime {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-break_time_extra_time');
    return localizationData?.value ?? '';
  }

  static String get penality {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penality');
    return localizationData?.value ?? '';
  }

  static String get suspended {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-suspended');
    return localizationData?.value ?? '';
  }

  static String get temporarilyCancelled {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-temporarily_cancelled');
    return localizationData?.value ?? '';
  }

  static String get finished {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-finished');
    return localizationData?.value ?? '';
  }

  static String get finishedExtraTime {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-finished_extra_time');
    return localizationData?.value ?? '';
  }

  static String get finishedByPenality {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-finished_by_penality');
    return localizationData?.value ?? '';
  }

  static String get postponed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-postponed');
    return localizationData?.value ?? '';
  }

  static String get cancelled {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cancelled');
    return localizationData?.value ?? '';
  }

  static String get abandoned {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-abandoned');
    return localizationData?.value ?? '';
  }

  static String get technicalLoss {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-technical_loss');
    return localizationData?.value ?? '';
  }

  static String get walkOver {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-walkOver');
    return localizationData?.value ?? '';
  }

  static String get live {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-live');
    return localizationData?.value ?? '';
  }

  static String get europaLeagueShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-europa_league_short');
    return localizationData?.value ?? '';
  }

  static String get africanChampionsLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-african_champions_league');
    return localizationData?.value ?? '';
  }

  static String get relegation {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-relegation');
    return localizationData?.value ?? '';
  }

  static String get nextRoundQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-next_round_qualification');
    return localizationData?.value ?? '';
  }

  static String get europeChampionsLeagueKnockout {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-europe_champions_league_knockout');
    return localizationData?.value ?? '';
  }

  static String get cafConfederationCup {
    final languageCode = localLanguageNotifier.value;

    final localizationData = _box.get('$languageCode-caf_confederation_cup');
    return localizationData?.value ?? '';
  }

  static String get europaConferenceLeagueQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-europa_conference_league_qualification');
    return localizationData?.value ?? '';
  }

  static String get relegationQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-relegation_qualification');
    return localizationData?.value ?? '';
  }

  static String get championsLeagueQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-champions_league_qualification');
    return localizationData?.value ?? '';
  }

  static String get asiaFootballConfederationChampionsLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-asia_football_confederation_champions_league');
    return localizationData?.value ?? '';
  }

  static String get asiaFootballConfederationCup {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-asia_football_confederation_cup');
    return localizationData?.value ?? '';
  }

  static String get group {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-group');
    return localizationData?.value ?? '';
  }

  static String get winner {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-winner');
    return localizationData?.value ?? '';
  }

  static String get looser {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-looser');
    return localizationData?.value ?? '';
  }

  static String get drawer {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-drawer');
    return localizationData?.value ?? '';
  }

  static String get w {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-w');
    return localizationData?.value ?? '';
  }

  static String get d {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-d');
    return localizationData?.value ?? '';
  }

  static String get l {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-l');
    return localizationData?.value ?? '';
  }

  static String get additional {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-additional');
    return localizationData?.value ?? '';
  }

  static String get ethiopian {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ethiopian');
    return localizationData?.value ?? '';
  }

  static String get european {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-european');
    return localizationData?.value ?? '';
  }

  static String get english {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-english');
    return localizationData?.value ?? '';
  }

  static String get asian {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-asian');
    return localizationData?.value ?? '';
  }

  static String get african {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-african');
    return localizationData?.value ?? '';
  }

  static String get oceania {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-oceania');
    return localizationData?.value ?? '';
  }

  static String get north_america {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-north_america');
    return localizationData?.value ?? '';
  }

  static String get south_america {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-south_america');
    return localizationData?.value ?? '';
  }

  static String get others {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-others');
    return localizationData?.value ?? '';
  }

  static String get arsenal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-arsenal');
    return localizationData?.value ?? '';
  }

  static String get manchesterUnited {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-manchester_united');
    return localizationData?.value ?? '';
  }

  static String get liverpool {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-liverpool');
    return localizationData?.value ?? '';
  }

  static String get manchesterCity {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-manchester_city');
    return localizationData?.value ?? '';
  }

  static String get chelsea {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-chelsea');
    return localizationData?.value ?? '';
  }

  static String get southampton {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-southampton');
    return localizationData?.value ?? '';
  }

  static String get newcastle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-newcastle');
    return localizationData?.value ?? '';
  }

  static String get bournemouth {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bournemouth');
    return localizationData?.value ?? '';
  }

  static String get fulham {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fulham');
    return localizationData?.value ?? '';
  }

  static String get astonVilla {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-aston_villa');
    return localizationData?.value ?? '';
  }

  static String get brentford {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-brentford');
    return localizationData?.value ?? '';
  }

  static String get brighton {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-brighton');
    return localizationData?.value ?? '';
  }

  static String get crystalPalace {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-crystal_palace');
    return localizationData?.value ?? '';
  }

  static String get everton {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-everton');
    return localizationData?.value ?? '';
  }

  static String get leedsUnited {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leeds_united');
    return localizationData?.value ?? '';
  }

  static String get leicesterCity {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leicester_city');
    return localizationData?.value ?? '';
  }

  static String get nottinghamForest {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-nottingham_forest');
    return localizationData?.value ?? '';
  }

  static String get wolves {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wolves');
    return localizationData?.value ?? '';
  }

  static String get tottenhamHotspur {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tottenham_hotspur');
    return localizationData?.value ?? '';
  }

  static String get westHamUnited {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-west_ham_united');
    return localizationData?.value ?? '';
  }

  static String get next {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-next');
    return localizationData?.value ?? '';
  }

  static String get realMadrid {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-real_madrid');
    return localizationData?.value ?? '';
  }

  static String get sassuolo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sassuolo');
    return localizationData?.value ?? '';
  }

  static String get bayernMunich {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bayern_munich');
    return localizationData?.value ?? '';
  }

  static String get nantes {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-nantes');
    return localizationData?.value ?? '';
  }

  static String get nice {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-nice');
    return localizationData?.value ?? '';
  }

  static String get parisSaintGermain {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-paris_saint_germain');
    return localizationData?.value ?? '';
  }

  static String get barcelona {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-barcelona');
    return localizationData?.value ?? '';
  }

  static String get atleticoBilbao {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-atletico_bilbao');
    return localizationData?.value ?? '';
  }

  static String get atleticoMadrid {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-atletico_madrid');
    return localizationData?.value ?? '';
  }

  static String get valencia {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-valencia');
    return localizationData?.value ?? '';
  }

  static String get villarreal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-villarreal');
    return localizationData?.value ?? '';
  }

  static String get lasPalmas {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-las_palmas');
    return localizationData?.value ?? '';
  }

  static String get angers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-angers');
    return localizationData?.value ?? '';
  }

  static String get bordeaux {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bordeaux');
    return localizationData?.value ?? '';
  }

  static String get lille {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-lille');
    return localizationData?.value ?? '';
  }

  static String get lyon {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-lyon');
    return localizationData?.value ?? '';
  }

  static String get marseille {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-marseille');
    return localizationData?.value ?? '';
  }

  static String get montpellier {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-montpellier');
    return localizationData?.value ?? '';
  }

  static String get malaga {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-malaga');
    return localizationData?.value ?? '';
  }

  static String get sevilla {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sevilla');
    return localizationData?.value ?? '';
  }

  static String get leganes {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-leganes');
    return localizationData?.value ?? '';
  }

  static String get espanyol {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-espanyol');
    return localizationData?.value ?? '';
  }

  static String get realSociedad {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-real_sociedad');
    return localizationData?.value ?? '';
  }

  static String get realBetis {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-real_betis');
    return localizationData?.value ?? '';
  }

  static String get alaves {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-alaves');
    return localizationData?.value ?? '';
  }

  static String get celtaVigo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-celta_vigo');
    return localizationData?.value ?? '';
  }

  static String get levante {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-levante');
    return localizationData?.value ?? '';
  }

  static String get getafe {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-getafe');
    return localizationData?.value ?? '';
  }

  static String get osasuna {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-osasuna');
    return localizationData?.value ?? '';
  }

  static String get granada {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-granada');
    return localizationData?.value ?? '';
  }

  static String get cadiz {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cadiz');
    return localizationData?.value ?? '';
  }

  static String get elche {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-elche');
    return localizationData?.value ?? '';
  }

  static String get huesca {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-huesca');
    return localizationData?.value ?? '';
  }

  static String get valladolid {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-valladolid');
    return localizationData?.value ?? '';
  }

  static String get eibar {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-eibar');
    return localizationData?.value ?? '';
  }

  static String get girona {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-girona');
    return localizationData?.value ?? '';
  }

  static String get toulouse {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-toulouse');
    return localizationData?.value ?? '';
  }

  static String get reims {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-reims');
    return localizationData?.value ?? '';
  }

  static String get strasbourg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-strasbourg');
    return localizationData?.value ?? '';
  }

  static String get rennes {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-rennes');
    return localizationData?.value ?? '';
  }

  static String get lens {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-lens');
    return localizationData?.value ?? '';
  }

  static String get saintEtienne {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saint_etienne');
    return localizationData?.value ?? '';
  }

  static String get monaco {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-monaco');
    return localizationData?.value ?? '';
  }

  static String get video {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-video');
    return localizationData?.value ?? '';
  }

  static String get fortunaDusseldorf {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fortuna_dusseldorf');
    return localizationData?.value ?? '';
  }

  static String get herthaBerlin {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-hertha_berlin');
    return localizationData?.value ?? '';
  }

  static String get scFreiburg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sc_freiburg');
    return localizationData?.value ?? '';
  }

  static String get vflWolfsburg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-vfl_wolfsburg');
    return localizationData?.value ?? '';
  }

  static String get werderBremen {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-werder_bremen');
    return localizationData?.value ?? '';
  }

  static String get borussiaMonchengladbach {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-borussia_mgladbach');
    return localizationData?.value ?? '';
  }

  static String get deportivoLaCoruna {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-deportivo_la_coruna');
    return localizationData?.value ?? '';
  }

  static String get mainz05 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-mainz_05');
    return localizationData?.value ?? '';
  }

  static String get borussiaDortmund {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-borussia_dortmund');
    return localizationData?.value ?? '';
  }

  static String get hannover96 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-hannover_96');
    return localizationData?.value ?? '';
  }

  static String get hoffenheim {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-hoffenheim');
    return localizationData?.value ?? '';
  }

  static String get bayerLeverkusen {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bayer_leverkusen');
    return localizationData?.value ?? '';
  }

  static String get eintrachtFrankfurt {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-eintracht_frankfurt');
    return localizationData?.value ?? '';
  }

  static String get fcAugsburg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fc_augsburg');
    return localizationData?.value ?? '';
  }

  static String get player_trait {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-player_trait');
    return localizationData?.value ?? '';
  }

  static String get Stats_compared {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-Stats_compared');
    return localizationData?.value ?? '';
  }

  static String get fcNurnberg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fc_nurnberg');
    return localizationData?.value ?? '';
  }

  static String get vfbStuttgart {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-vfb_stuttgart');
    return localizationData?.value ?? '';
  }

  static String get rbLeipzig {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-rb_leipzig');
    return localizationData?.value ?? '';
  }

  static String get schalke04 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-schalke_04');
    return localizationData?.value ?? '';
  }

  static String get hamburgerSv {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-hamburger_sv');
    return localizationData?.value ?? '';
  }

  static String get vflBochum {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-vfl_bochum');
    return localizationData?.value ?? '';
  }

  static String get jahnRegensburg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-jahn_regensburg');
    return localizationData?.value ?? '';
  }

  static String get spvggGreutherFurth {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-greuther_furth');
    return localizationData?.value ?? '';
  }

  static String get fcMagdeburg {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fc_magdeburg');
    return localizationData?.value ?? '';
  }

  static String get fcHeidenheim {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fc_heidenheim');
    return localizationData?.value ?? '';
  }

  static String get roma {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-roma');
    return localizationData?.value ?? '';
  }

  static String get lazio {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-lazio');
    return localizationData?.value ?? '';
  }

  static String get acMilan {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ac_milan');
    return localizationData?.value ?? '';
  }

  static String get cagliari {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cagliari');
    return localizationData?.value ?? '';
  }

  static String get chievo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-chievo');
    return localizationData?.value ?? '';
  }

  static String get napoli {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-napoli');
    return localizationData?.value ?? '';
  }

  static String get spal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-spal');
    return localizationData?.value ?? '';
  }

  static String get udinese {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-udinese');
    return localizationData?.value ?? '';
  }

  static String get genoa {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-genoa');
    return localizationData?.value ?? '';
  }

  static String get atleticoValencia {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-atletico_valencia');
    return localizationData?.value ?? '';
  }

  static String get bologna {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bologna');
    return localizationData?.value ?? '';
  }

  static String get crotone {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-crotone');
    return localizationData?.value ?? '';
  }

  static String get fiorentina {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fiorentina');
    return localizationData?.value ?? '';
  }

  static String get torino {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-torino');
    return localizationData?.value ?? '';
  }

  static String get verona {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-verona');
    return localizationData?.value ?? '';
  }

  static String get inter {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-inter');
    return localizationData?.value ?? '';
  }

  static String get benevento {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-benevento');
    return localizationData?.value ?? '';
  }

  static String get ascoli {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ascoli');
    return localizationData?.value ?? '';
  }

  static String get bari {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bari');
    return localizationData?.value ?? '';
  }

  static String get cesena {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cesena');
    return localizationData?.value ?? '';
  }

  static String get citadella {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cittadella');
    return localizationData?.value ?? '';
  }

  static String get pohangSteelers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-pohang_steelers');
    return localizationData?.value ?? '';
  }

  static String get urawaRedDiamonds {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-urawa_red_diamonds');
    return localizationData?.value ?? '';
  }

  static String get alNasr {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-al_nasr');
    return localizationData?.value ?? '';
  }

  static String get alHilal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-al_hilal');
    return localizationData?.value ?? '';
  }

  static String get ulsanHyundai {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ulsan_hyundai');
    return localizationData?.value ?? '';
  }

  static String get persepolis {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-persepolis');
    return localizationData?.value ?? '';
  }

  static String get kawasakiFrontale {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-kawasaki_frontale');
    return localizationData?.value ?? '';
  }

  static String get alDuhail {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-al_duhail');
    return localizationData?.value ?? '';
  }

  static String get alAhlyCairo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-al_ahly_cairo');
    return localizationData?.value ?? '';
  }

  static String get mamelodiSundowns {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-mamelodi_sundowns');
    return localizationData?.value ?? '';
  }

  static String get wydad {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wydad');
    return localizationData?.value ?? '';
  }

  static String get esTunis {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-es_tunis');
    return localizationData?.value ?? '';
  }

  static String get crBelouizdad {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cr_belouizdad');
    return localizationData?.value ?? '';
  }

  static String get dynamos {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dynamos');
    return localizationData?.value ?? '';
  }

  static String get tpMazembe {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-tp_mazembe');
    return localizationData?.value ?? '';
  }

  static String get platinumMazembe {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-platinum_mazembe');
    return localizationData?.value ?? '';
  }

  static String get kabylie {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-kabylie');
    return localizationData?.value ?? '';
  }

  static String get saintGeorge {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-saint_george');
    return localizationData?.value ?? '';
  }

  static String get ethiopiaBuna {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ethiopia_buna');
    return localizationData?.value ?? '';
  }

  static String get fasilKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fasil_kenema');
    return localizationData?.value ?? '';
  }

  static String get adamaKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-adama_kenema');
    return localizationData?.value ?? '';
  }

  static String get awassaKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-awassa_kenema');
    return localizationData?.value ?? '';
  }

  static String get bahirdarKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-bahirdar_kenema');
    return localizationData?.value ?? '';
  }

  static String get debubpolice {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-debub_police');
    return localizationData?.value ?? '';
  }

  static String get dedebit {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dedebit');
    return localizationData?.value ?? '';
  }

  static String get diredawaKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-diredawa_kenema');
    return localizationData?.value ?? '';
  }

  static String get Mekelakeya {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-mekelakeya');
    return localizationData?.value ?? '';
  }

  static String get mekelle70Enderta {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-mekelle_70_enderta');
    return localizationData?.value ?? '';
  }

  static String get sehulShire {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sehul_shire');
    return localizationData?.value ?? '';
  }

  static String get sidamaBuna {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sidama_buna');
    return localizationData?.value ?? '';
  }

  static String get wolaitaDicha {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wolaita_dicha');
    return localizationData?.value ?? '';
  }

  static String get wolloKobo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wollo_kobo');
    return localizationData?.value ?? '';
  }

  static String get arbaminchKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-arbaminch_kenema');
    return localizationData?.value ?? '';
  }

  static String get weldiyaKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-weldiya_kenema');
    return localizationData?.value ?? '';
  }

  static String get ethiopiaNigdBank {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-cbe');
    return localizationData?.value ?? '';
  }

  static String get jimmaAbabuna {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-jimma_ababuna');
    return localizationData?.value ?? '';
  }

  static String get hadiyaHossana {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-hadiya_hossana');
    return localizationData?.value ?? '';
  }

  static String get sebetaKenema {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sebeta_kenema');
    return localizationData?.value ?? '';
  }

  static String get ethiopiaMedhin {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ethiopia_medhin');
    return localizationData?.value ?? '';
  }

  static String get Legetafolegedadi {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-Legetafo_legedadi');
    return localizationData?.value ?? '';
  }

  static String get juventus {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-juventus');
    return localizationData?.value ?? '';
  }

  static String get asRoma {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-as_roma');
    return localizationData?.value ?? '';
  }

  static String get sampdoria {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sampdoria');
    return localizationData?.value ?? '';
  }

  static String get mbombelaUnited {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-mbombela_united');
    return localizationData?.value ?? '';
  }

  static String get teams {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-teams');
    return localizationData?.value ?? '';
  }

  static String get africanWcQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-african_wc_qualification');
    return localizationData?.value ?? '';
  }

  static String get europeanWcQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-european_wc_qualification');
    return localizationData?.value ?? '';
  }

  static String get northAmericanWcQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-north_american_wc_qualification');
    return localizationData?.value ?? '';
  }

  static String get southAmericanWcQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-south_american_wc_qualification');
    return localizationData?.value ?? '';
  }

  static String get asianWcQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-asian_wc_qualification');
    return localizationData?.value ?? '';
  }

  static String get oceaniaWcQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-oceania_wc_qualification');
    return localizationData?.value ?? '';
  }

  static String get englishLeagueOne {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-english_league_one');
    return localizationData?.value ?? '';
  }

  static String get englishLeagueOneShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-english_league_one_short');
    return localizationData?.value ?? '';
  }

  static String get englishLeagueTwo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-english_league_two');
    return localizationData?.value ?? '';
  }

  static String get englishLeagueTwoShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-english_league_two_short');
    return localizationData?.value ?? '';
  }

  static String get englishChampionsShip {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-english_champions_ship');
    return localizationData?.value ?? '';
  }

  static String get englishChampionsShipShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-english_champions_ship_short');
    return localizationData?.value ?? '';
  }

  static String get africanCup {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-african_cup');
    return localizationData?.value ?? '';
  }

  static String get africanCupShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-african_cup_short');
    return localizationData?.value ?? '';
  }

  static String get europeanCup {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-european_cup');
    return localizationData?.value ?? '';
  }

  static String get europeanCupShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-european_cup_short');
    return localizationData?.value ?? '';
  }

  static String get wcQualification {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wc_qualification');
    return localizationData?.value ?? '';
  }

  static String get wcQualificationShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wc_qualification_short');
    return localizationData?.value ?? '';
  }

  static String get europeanNationsLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-european_nations_league');
    return localizationData?.value ?? '';
  }

  static String get europeanNationsLeagueShort {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-european_nations_league_short');
    return localizationData?.value ?? '';
  }

  static String get card_upgrade {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-card_upgrade');
    return localizationData?.value ?? 'Card upgraded to Red';
  }

  static String get goalCancelled {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal_cancelled');
    return localizationData?.value ?? '';
  }

  static String get goalEvent {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal');
    return localizationData?.value ?? '';
  }

  static String get varEvent {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-var');
    return localizationData?.value ?? '';
  }

  static String get redCard {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-red_card');
    return localizationData?.value ?? '';
  }

  static String get subst {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-subst');
    return localizationData?.value ?? '';
  }

  static String get belgiumJupilerProLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-belgium_jupiler_pro_league');
    return localizationData?.value ?? '';
  }

  static String get netherlandEredivisie {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-netherland_erdivisie');
    return localizationData?.value ?? '';
  }

  static String get portugalPrimeiraLiga {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-portugal_primeira_liga');
    return localizationData?.value ?? '';
  }

  static String get scotlandPremiership {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-scotland_premiership');
    return localizationData?.value ?? '';
  }

  static String get southAfricaPremierSoccerLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-south_africa_premier_soccer_league');
    return localizationData?.value ?? '';
  }

  static String get turkTurkLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-turk_turk_league');
    return localizationData?.value ?? '';
  }

  static String get copaAmerica {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-copa_america');
    return localizationData?.value ?? '';
  }

  static String get asianCup {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-asian_cup');
    return localizationData?.value ?? '';
  }

  static String get goldCup {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-gold_cup');
    return localizationData?.value ?? '';
  }

  static String get africanFootballLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-african_football_league');
    return localizationData?.value ?? '';
  }

  static String get afcChampionsLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-afc_champions_league');
    return localizationData?.value ?? '';
  }

  static String get afcCup {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-afc_cup');
    return localizationData?.value ?? '';
  }

  static String get cafChampionsLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-caf_champions_league');
    return localizationData?.value ?? '';
  }

  static String get africanNationsChampionship {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-african_nations_championship');
    return localizationData?.value ?? '';
  }

  static String get spainSegundaDivision {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-spain_segunda_division');
    return localizationData?.value ?? '';
  }

  static String get italySerieB {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-italy_serie_b');
    return localizationData?.value ?? '';
  }

  static String get serieC {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-serie_c');
    return localizationData?.value ?? '';
  }

  static String get turkeyLig1 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-turkey_lig_1');
    return localizationData?.value ?? '';
  }

  static String get qatarStarsLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-qatar_stars_league');
    return localizationData?.value ?? '';
  }

  static String get belgiumChallengerProLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-belgium_challenger_pro_league');
    return localizationData?.value ?? '';
  }

  static String get netherlandsEersteDivisie {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-netherlands_eerste_divisie');
    return localizationData?.value ?? '';
  }

  static String get portugalLigaPortugal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-portugal_liga_portugal');
    return localizationData?.value ?? '';
  }

  static String get germanyBundesliga2 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-germany_bundesliga_2');
    return localizationData?.value ?? '';
  }

  static String get germanyLiga3 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-germany_liga_3');
    return localizationData?.value ?? '';
  }

  static String get franceLigue2 {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-france_ligue_2');
    return localizationData?.value ?? '';
  }

  static String get championnatNational {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-championnat_national');
    return localizationData?.value ?? '';
  }

  static String get brazilSerieA {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-brazil_serie_a');
    return localizationData?.value ?? '';
  }

  static String get brazilSerieB {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-brazil_serie_b');
    return localizationData?.value ?? '';
  }

  static String get brazilSerieC {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-brazil_serie_c');
    return localizationData?.value ?? '';
  }

  static String get ligaProfesionalArgentina {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-liga_profesional_argentina');
    return localizationData?.value ?? '';
  }

  static String get argentinaPrimeraNacional {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-argentina_primera_nacional');
    return localizationData?.value ?? '';
  }

  static String get copaArgentina {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-copa_argentina');
    return localizationData?.value ?? '';
  }

  static String get usaMajorLeagueSoccer {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-usa_major_league_soccer');
    return localizationData?.value ?? '';
  }

  static String get uslChampionship {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-usl_championship');
    return localizationData?.value ?? '';
  }

  static String get uslLeagueOne {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-usl_league_one');
    return localizationData?.value ?? '';
  }

  static String get egyptPremierLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-egypt_premier_league');
    return localizationData?.value ?? '';
  }

  static String get ghanaPremierLeague {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ghana_premier_league');
    return localizationData?.value ?? '';
  }

  static String get scotlandChampionship {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-scotland_championship');
    return localizationData?.value ?? '';
  }

  static String get matchStarted {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-match_started');
    return localizationData?.value ?? '';
  }

  static String get fifteenMinutesLeft {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-15_minutes_left');
    return localizationData?.value ?? '';
  }

  static String get matchEnded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-match_ended');
    return localizationData?.value ?? '';
  }

  static String get secondHalfBegun {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-second_half_begun');
    return localizationData?.value ?? '';
  }

  static String get lineUp {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-lineup');
    return localizationData?.value ?? '';
  }

  static String get matchReminder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-match_reminder');
    return localizationData?.value ?? '';
  }

  static String get missedPenality {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-missed_penality');
    return localizationData?.value ?? '';
  }

  static String get statistics {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-statistics');
    return localizationData?.value ?? '';
  }

  static String get detail {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-detail');
    return localizationData?.value ?? '';
  }

  static String get ballPossession {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-ball_possession');
    return localizationData?.value ?? '';
  }

  static String get totalGoalTrials {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_goal_trial');
    return localizationData?.value ?? '';
  }

  static String get successfulPasses {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-successful_passes');
    return localizationData?.value ?? '';
  }

  static String get offsideGame {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-offside');
    return localizationData?.value ?? '';
  }

  static String get cornerKick {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-corner_kick');
    return localizationData?.value ?? '';
  }

  static String get goalTrials {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal_trials');
    return localizationData?.value ?? '';
  }

  static String get totalGoalTrialss {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_goal_trials');
    return localizationData?.value ?? '';
  }

  static String get goalsOfftarget {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goals_offtarget');
    return localizationData?.value ?? '';
  }

  static String get goalsOntarget {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goals_ontarget');
    return localizationData?.value ?? '';
  }

  static String get goalsOnTarget {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goals_on_target');
    return localizationData?.value ?? '';
  }

  static String get blockedGoalTrials {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-blocked_goal_trials');
    return localizationData?.value ?? '';
  }

  static String get goalTrialsInsideBox {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal_trials_inside_box');
    return localizationData?.value ?? '';
  }

  static String get goalTrialsOutsideBox {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal_trials_outside_box');
    return localizationData?.value ?? '';
  }

  static String get round {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-round');
    return localizationData?.value ?? '';
  }

  static String get register {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-register');
    return localizationData?.value ?? '';
  }

  static String get yellowCard {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-yellow_card');
    return localizationData?.value ?? '';
  }

  static String get sound {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sound');
    return localizationData?.value ?? '';
  }

  static String get vibration {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-vibration');
    return localizationData?.value ?? '';
  }

  static String get transferNews {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-transfer_news');
    return localizationData?.value ?? '';
  }

  static String get officialHighlights {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-official_highlights');
    return localizationData?.value ?? '';
  }

  static String get done {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-done');
    return localizationData?.value ?? '';
  }

  static String get liveScore {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-live_score');
    return localizationData?.value ?? '';
  }

  static String get type {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-type');
    return localizationData?.value ?? '';
  }

  static String get notificationsEnabled {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notifications_enabled');
    return localizationData?.value ?? '';
  }

  static String get breakingNews {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-breaking_news');
    return localizationData?.value ?? '';
  }

  static String get topGoalScorer {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-top_goal_scorer');
    return localizationData?.value ?? '';
  }

  static String get listenToYourFavouriteSportProgram {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-listen_to_your_favourite_sport_program');
    return localizationData?.value ?? '';
  }

  static String get minutes90End {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-90_minutes_end');
    return localizationData?.value ?? '';
  }

  static String get started {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-started');
    return localizationData?.value ?? '';
  }

  static String get manager {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-manager');
    return localizationData?.value ?? '';
  }

  static String get substitutionPlayers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-substitution_players');
    return localizationData?.value ?? '';
  }

  static String get coach {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-coach');
    return localizationData?.value ?? '';
  }

  static String get team {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-team');
    return localizationData?.value ?? '';
  }

  static String get goalsScored {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goals_scored');
    return localizationData?.value ?? '';
  }

  static String get byMinute {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-by_minute');
    return localizationData?.value ?? '';
  }

  static String get scoredGoals {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-scored_goals');
    return localizationData?.value ?? '';
  }

  static String get counted {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-counted');
    return localizationData?.value ?? '';
  }

  static String get theyAreWrong {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-they_are_wrong');
    return localizationData?.value ?? '';
  }

  static String get goalkeepers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goalkeepers');
    return localizationData?.value ?? '';
  }

  static String get defenders {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-defenders');
    return localizationData?.value ?? '';
  }

  static String get averages {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-averages');
    return localizationData?.value ?? '';
  }

  static String get attackers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-attackers');
    return localizationData?.value ?? '';
  }

  static String get playerInformationNotAvailable {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-player_information_not_available');
    return localizationData?.value ?? '';
  }

  static String get informationNotFound {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-information_not_found');
    return localizationData?.value ?? '';
  }

  static String get last5Games {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-last_5_games');
    return localizationData?.value ?? '';
  }

  static String get playersProfile {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-players_profile');
    return localizationData?.value ?? '';
  }

  static String get unableToFindPlayerInformation {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-unable_to_find_player_information');
    return localizationData?.value ?? '';
  }

  static String get onInjury {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-on_injury');
    return localizationData?.value ?? '';
  }

  static String get itDoesNotHaveTo {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-it_does_not_have_to');
    return localizationData?.value ?? '';
  }

  static String get name {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-name');
    return localizationData?.value ?? '';
  }

  static String get age {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-age');
    return localizationData?.value ?? '';
  }

  static String get height {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-height');
    return localizationData?.value ?? '';
  }

  static String get weight {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-weight');
    return localizationData?.value ?? '';
  }

  static String get countryOfOrigin {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-country_of_origin');
    return localizationData?.value ?? '';
  }

  static String get citizenship {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-citizenship');
    return localizationData?.value ?? '';
  }

  static String get playground {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-playground');
    return localizationData?.value ?? '';
  }

  static String get averageRating {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-average_rating');
    return localizationData?.value ?? '';
  }

  static String get numberOfGames {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-number_of_games');
    return localizationData?.value ?? '';
  }

  static String get minutesPlayed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-minutes_played');
    return localizationData?.value ?? '';
  }

  static String get whatHasChanged {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-what_has_changed');
    return localizationData?.value ?? '';
  }

  static String get changed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-changed');
    return localizationData?.value ?? '';
  }

  static String get waiter {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-waiter');
    return localizationData?.value ?? '';
  }

  static String get generalTest {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-general_test');
    return localizationData?.value ?? '';
  }

  static String get targetedTesting {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-targeted_testing');
    return localizationData?.value ?? '';
  }

  static String get theNumberOfGoalsScored {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-the_number_of_goals_scored');
    return localizationData?.value ?? '';
  }

  static String get heAcceptedForTheGoal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-he_accepted_for_the_goal');
    return localizationData?.value ?? '';
  }

  static String get whoSavedHim {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-who_saved_him');
    return localizationData?.value ?? '';
  }

  static String get generalAccepted {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-general_accepted');
    return localizationData?.value ?? '';
  }

  static String get keyRelay {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-key_relay');
    return localizationData?.value ?? '';
  }

  static String get relaySuccess {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-relay_success');
    return localizationData?.value ?? '';
  }

  static String get totalTackle {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_tackle');
    return localizationData?.value ?? '';
  }

  static String get totalBlocks {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_blocks');
    return localizationData?.value ?? '';
  }

  static String get totalInterceptions {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_interceptions');
    return localizationData?.value ?? '';
  }

  static String get duelsTotal {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-duels_total');
    return localizationData?.value ?? '';
  }

  static String get duelsWon {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-duels_won');
    return localizationData?.value ?? '';
  }

  static String get dribbleAttempts {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dribble_attempts');
    return localizationData?.value ?? '';
  }

  static String get dribbleSuccess {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dribble_success');
    return localizationData?.value ?? '';
  }

  static String get foulsDrawn {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-fouls_drawn');
    return localizationData?.value ?? '';
  }

  static String get committedFouls {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-committed_fouls');
    return localizationData?.value ?? '';
  }

  static String get yellowCards {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-yellow_cards');
    return localizationData?.value ?? '';
  }

  static String get yellowRedCards {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-yellow_red_cards');
    return localizationData?.value ?? '';
  }

  static String get penaltyWon {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penalty_won');
    return localizationData?.value ?? '';
  }

  static String get penaltyCommitted {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penalty_committed');
    return localizationData?.value ?? '';
  }

  static String get penalty_scored {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penalty_scored');
    return localizationData?.value ?? 'Penalty scored';
  }

  static String get penalty_missed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penalty_missed');
    return localizationData?.value ?? 'Penalty missed';
  }

  static String get foul {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-foul');
    return localizationData?.value ?? 'Foul';
  }

  static String get argument {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-argument');
    return localizationData?.value ?? 'Argument';
  }

  static String get handball {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-handball');
    return localizationData?.value ?? 'Handball';
  }

  static String get violent_conduct {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-violent_conduct');
    return localizationData?.value ?? 'Violent conduct';
  }

  static String get diving {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-diving');
    return localizationData?.value ?? 'Diving';
  }

  static String get time_wasting {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-time_wasting');
    return localizationData?.value ?? 'Time wasting';
  }

  static String get unsporting_behavior {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-unsporting_behavior');
    return localizationData?.value ?? 'Unsporting behavior';
  }

  static String get second_yellow {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-second_yellow');
    return localizationData?.value ?? 'Second yellow card';
  }

  static String get professional_foul {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-professional_foul');
    return localizationData?.value ?? 'Professional foul';
  }

  static String get excessive_celebration {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-excessive_celebration');
    return localizationData?.value ?? 'Excessive celebration';
  }

  static String get penaltySaved {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-penalty_saved');
    return localizationData?.value ?? '';
  }

  static String get totalPass {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_pass');
    return localizationData?.value ?? '';
  }

  static String get dribblesPast {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-dribbles_past');
    return localizationData?.value ?? '';
  }

  static String get onTargetTrials {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-on_target_trials');
    return localizationData?.value ?? '';
  }

  static String get totalGoalsScored {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_goals_scored');
    return localizationData?.value ?? '';
  }

  static String get totalGoalsConceded {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-total_goals_conceded');
    return localizationData?.value ?? '';
  }

  static String get goalKeepers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goal_keepers');
    return localizationData?.value ?? '';
  }

  static String get midFielders {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-mid_fielders');
    return localizationData?.value ?? '';
  }

  static String get strikers {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-strikers');
    return localizationData?.value ?? '';
  }

  static String get jerseyNumber {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-jersey_number');
    return localizationData?.value ?? '';
  }

  static String get whoToCall {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-who_to_call');
    return localizationData?.value ?? '';
  }

  static String get field {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-field');
    return localizationData?.value ?? '';
  }

  static String get judge {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-judge');
    return localizationData?.value ?? '';
  }

  static String get phoneNumber {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-phone_number');
    return localizationData?.value ?? '';
  }

  static String get sms_confirmation {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sms_confirmation');
    return localizationData?.value ?? '';
  }

  static String get sms_redirect_message {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-sms_redirect_message');
    return localizationData?.value ?? '';
  }

  static String get enter_valid_phone_number {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enter_valid_phone_number');
    return localizationData?.value ?? '';
  }

  static String get enter_phone_number {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enter_phone_number');
    return localizationData?.value ?? '';
  }

  static String get enter_your_phone_number {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enter_your_phone_number');
    return localizationData?.value ?? '';
  }

  static String get phoneNumberNotFound {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-phone_number_not_found');
    return localizationData?.value ?? '';
  }

  static String get guess {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-guess');
    return localizationData?.value ?? '';
  }

  static String get missedGoals {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-missed_goals');
    return localizationData?.value ?? '';
  }

  static String get unableToFindSharedGames {
    final languageCode = localLanguageNotifier.value;
    final localizationData =
        _box.get('$languageCode-unable_to_find_shared_games');
    return localizationData?.value ?? '';
  }

  static String get unableToFindAlignment {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-unable_to_find_alignment');
    return localizationData?.value ?? '';
  }

  static String get regularSeason {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-regularSeason');
    return localizationData?.value ?? '';
  }

  static String get finalmatch {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-finalmatch');
    return localizationData?.value ?? '';
  }

  static String get quarterFinals {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-quarterFinals');
    return localizationData?.value ?? '';
  }

  static String get semiFinals {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-semiFinals');
    return localizationData?.value ?? '';
  }

  static String get roundOf {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-roundOf');
    return localizationData?.value ?? '';
  }

  static String get guess_who_will_win {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-guess_who_will_win');
    return localizationData?.value ?? '';
  }

  static String get passwordIncorrect {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-password_incorrect');
    return localizationData?.value ?? '';
  }

  static String get passwordExpired {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-password_expired');
    return localizationData?.value ?? '';
  }

  static String get enterCode {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enter_code');
    return localizationData?.value ?? '';
  }

  static String get noGameToday {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-no_game_today');
    return localizationData?.value ?? '';
  }

  static String get enableNotifications {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enableNotifications');
    return localizationData?.value ?? '';
  }

  static String get stayUpdatedWith {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-stayUpdatedWith');
    return localizationData?.value ?? '';
  }

  static String get liveMatchUpdates {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-liveMatchUpdates');
    return localizationData?.value ?? '';
  }

  static String get goalAlerts {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-goalAlerts');
    return localizationData?.value ?? '';
  }

  static String get matchReminders {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-matchReminders');
    return localizationData?.value ?? '';
  }

  static String get notNow {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-notNow');
    return localizationData?.value ?? '';
  }

  static String get openSettings {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-openSettings');
    return localizationData?.value ?? '';
  }

  static String get enable {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-enable');
    return localizationData?.value ?? '';
  }

  static String get minutes {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-minutes');
    return localizationData?.value ?? '';
  }

  static String get hours {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-hours');
    return localizationData?.value ?? '';
  }

  static String get kickoff {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-kickoff');
    return localizationData?.value ?? '';
  }

  static String get left {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-left');
    return localizationData?.value ?? '';
  }

  static String get resendCodeIn {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-resend_code_in');
    return localizationData?.value ?? '';
  }

  static String get invalidOTP {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-invalid_otp');
    return localizationData?.value ?? '';
  }

  static String get otpExpired {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-otp_expired');
    return localizationData?.value ?? '';
  }

  static String get serverError {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-server_error');
    return localizationData?.value ?? '';
  }

  static of(BuildContext context, String selectedLanguage) {}

  static String get addProfilePicture {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-add_profile_picture');
    return localizationData?.value ?? '';
  }

  static String get chooseProfilePicture {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-choose_profile_picture');
    return localizationData?.value ?? '';
  }

  static String get skip {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-skip');
    return localizationData?.value ?? '';
  }

  static String get choosePhoto {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-choose_photo');
    return localizationData?.value ?? '';
  }

  static String get profilePictureUpdated {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-profile_picture_updated');
    return localizationData?.value ?? '';
  }

  static String get uploadImageFailed {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-upload_image_failed');
    return localizationData?.value ?? '';
  }

  static String get uploadImageError {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-upload_image_error');
    return localizationData?.value ?? '';
  }

  static String get exitQuiz {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-exitQuiz');
    return localizationData?.value ?? '';
  }

  static String get exitQuizConfirmation {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-exitQuizConfirmation');
    return localizationData?.value ?? '';
  }

  static String get exit {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-exit');
    return localizationData?.value ?? '';
  }

  static String get defender {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-defender');
    return localizationData?.value ?? '';
  }

  static String get midfielder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-midfielder');
    return localizationData?.value ?? '';
  }

  static String get attacker {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-attacker');
    return localizationData?.value ?? '';
  }

  static String get defense {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-defense');
    return localizationData?.value ?? '';
  }

  static String get wingBack {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-wingBack');
    return localizationData?.value ?? '';
  }

  static String get falseNine {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-falseNine');
    return localizationData?.value ?? '';
  }

  static String get libero {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-libero');
    return localizationData?.value ?? '';
  }

  static String get boxToBoxMidfielder {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-boxToBoxMidfielder');
    return localizationData?.value ?? '';
  }

  static String get playmaker {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-playmaker');
    return localizationData?.value ?? '';
  }

  static String get targetMan {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-targetMan');
    return localizationData?.value ?? '';
  }

  static String get trequartista {
    final languageCode = localLanguageNotifier.value;
    final localizationData = _box.get('$languageCode-trequartista');
    return localizationData?.value ?? '';
  }
}

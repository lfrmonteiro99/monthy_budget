import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('farPastDate is year 2000', () {
      expect(AppConstants.farPastDate.year, 2000);
    });

    test('duration constants are positive', () {
      expect(AppConstants.resumeDebounce.inSeconds, 30);
      expect(AppConstants.rateLimitInterval.inSeconds, 3);
      expect(AppConstants.commandChatTimeout.inSeconds, 12);
      expect(AppConstants.groceryFetchTimeout.inSeconds, 15);
      expect(AppConstants.geoLocationTimeout.inSeconds, 10);
      expect(AppConstants.snackBarShort.inSeconds, 2);
      expect(AppConstants.snackBarMedium.inSeconds, 4);
      expect(AppConstants.snackBarLong.inSeconds, 5);
      expect(AppConstants.snackBarUndo.inSeconds, 8);
      expect(AppConstants.animFast.inMilliseconds, 200);
      expect(AppConstants.animScrollToBottom.inMilliseconds, 220);
      expect(AppConstants.animStandard.inMilliseconds, 250);
      expect(AppConstants.animPageTransition.inMilliseconds, 300);
      expect(AppConstants.animProgressBar.inMilliseconds, 400);
      expect(AppConstants.animBounce.inMilliseconds, 500);
      expect(AppConstants.animHealthRing.inMilliseconds, 600);
      expect(AppConstants.animFabPulse.inMilliseconds, 1000);
      expect(AppConstants.animBrandedLoading.inMilliseconds, 1400);
      expect(AppConstants.fabFirstUseDismiss.inMilliseconds, 3000);
      expect(AppConstants.tourStartDelay.inMilliseconds, 500);
      expect(AppConstants.nearFutureReminder.inMinutes, 1);
      expect(AppConstants.recommendationAutoDismiss.inSeconds, 8);
    });
  });

  group('AppTab', () {
    test('navigationIndex maps correctly', () {
      expect(AppTab.dashboard.navigationIndex, 0);
      expect(AppTab.expenses.navigationIndex, 1);
      expect(AppTab.planHub.navigationIndex, 2);
      expect(AppTab.more.navigationIndex, 3);
    });

    test('featureKey maps correctly', () {
      expect(AppTab.dashboard.featureKey, 'dashboard');
      expect(AppTab.expenses.featureKey, 'expense_tracker');
      expect(AppTab.planHub.featureKey, 'plan_and_shop');
      expect(AppTab.more.featureKey, 'more');
    });

    test('fromNavigationIndex returns correct tab', () {
      expect(AppTab.fromNavigationIndex(0), AppTab.dashboard);
      expect(AppTab.fromNavigationIndex(1), AppTab.expenses);
      expect(AppTab.fromNavigationIndex(2), AppTab.planHub);
      expect(AppTab.fromNavigationIndex(3), AppTab.more);
    });

    test('fromNavigationIndex throws on invalid index', () {
      expect(() => AppTab.fromNavigationIndex(4), throwsA(isA<RangeError>()));
      expect(() => AppTab.fromNavigationIndex(-1), throwsA(isA<RangeError>()));
    });

    test('values contains all tabs', () {
      expect(AppTab.values, hasLength(4));
      expect(AppTab.values, contains(AppTab.dashboard));
      expect(AppTab.values, contains(AppTab.expenses));
      expect(AppTab.values, contains(AppTab.planHub));
      expect(AppTab.values, contains(AppTab.more));
    });
  });
}

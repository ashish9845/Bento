import 'package:flutter_bloc/flutter_bloc.dart';

import 'error_reporting.dart';

/// Global observer, installed in `main()` before `runApp`.
///
/// Every `addError` from any Bloc/Cubit lands here and is printed to the
/// console via [ErrorReporting.log] — deliberately *not* sent to Sentry,
/// so routine handled errors (cancelled scans, failed prefs writes, …)
/// don't become Sentry events. Truly fatal crashes still reach Sentry
/// through the FlutterError/PlatformDispatcher handlers in `main()`.
/// State changes are not logged, to keep the pipeline quiet.
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    ErrorReporting.log(
      error,
      stackTrace,
      context: 'bloc:${bloc.runtimeType}',
    );
    super.onError(bloc, error, stackTrace);
  }
}

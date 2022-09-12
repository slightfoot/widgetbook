import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:widgetbook/src/extensions/enum_extension.dart';
import 'package:widgetbook/src/navigation/preview_provider.dart';
import 'package:widgetbook/src/widgetbook_page.dart';
import 'package:widgetbook/src/workbench/workbench_provider.dart';

void refreshRoute<CustomTheme>({
  required WorkbenchProvider<CustomTheme> workbenchProvider,
  required PreviewProvider previewProvider,
}) {
  final previewState = previewProvider.state;
  final workbenchState = workbenchProvider.state;

  final queryParameters = <String, String>{};

  if (workbenchState.hasSelectedTheme) {
    queryParameters.putIfAbsent(
      'theme',
      () => workbenchState.theme!.name,
    );
  }

  if (workbenchState.hasSelectedLocale) {
    queryParameters.putIfAbsent(
      'locale',
      () => workbenchState.locale!.languageCode,
    );
  }

  if (workbenchState.hasSelectedDevice) {
    queryParameters.putIfAbsent(
      'device',
      () => workbenchState.device!.name,
    );
  }

  if (workbenchState.hasSelectedTextScaleFactor) {
    queryParameters.putIfAbsent(
      'text-scale-factor',
      () => workbenchState.textScaleFactor!.toStringAsFixed(1),
    );
  }

  queryParameters
    ..putIfAbsent(
      'orientation',
      () => workbenchState.orientation.toShortString(),
    )
    ..putIfAbsent(
      'frame',
      () => workbenchState.frame.name,
    );

  if (previewState.isUseCaseSelected) {
    queryParameters.putIfAbsent(
      'path',
      () => previewState.selectedUseCase!.path,
    );
  }

  final uri = Uri.parse('/').replace(queryParameters: queryParameters);

  // Little hack to update the URL without changing the route itself.
  SystemChannels.navigation.invokeMethod<void>(
    'routeUpdated',
    <String, dynamic>{'routeName': uri.toString()},
  );
}

bool _parseBoolQueryParameter({
  required String? value,
  bool defaultValue = false,
}) {
  if (value == null) {
    return defaultValue;
  }

  return value == 'true';
}

RouteFactory? createRouteFactory<CustomTheme>({
  required BuildContext context,
  required WorkbenchProvider<CustomTheme> workbenchProvider,
  required PreviewProvider previewProvider,
}) {
  previewProvider.addListener(() {
    refreshRoute(
      workbenchProvider: workbenchProvider,
      previewProvider: previewProvider,
    );
  });

  workbenchProvider.addListener(() {
    refreshRoute(
      workbenchProvider: workbenchProvider,
      previewProvider: previewProvider,
    );
  });

  return (RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? Navigator.defaultRouteName);
    if (uri.path != '/') {
      return null;
    }

    final theme = uri.queryParameters['theme'];
    final locale = uri.queryParameters['locale'];
    final device = uri.queryParameters['device'];
    final textScaleFactor = uri.queryParameters['text-scale-factor'];
    final orientation = uri.queryParameters['orientation'];
    final frame = uri.queryParameters['frame'];
    final path = uri.queryParameters['path'];

    workbenchProvider
      ..setThemeByName(theme)
      ..setLocaleByName(locale)
      ..setDeviceByName(device)
      ..setTextScaleFactorByName(textScaleFactor)
      ..setOrientationByName(orientation)
      ..setFrameByName(frame);

    previewProvider.selectUseCaseByPath(path);

    final disableNavigation = _parseBoolQueryParameter(
      value: uri.queryParameters['disable-navigation'],
    );
    final disableProperties = _parseBoolQueryParameter(
      value: uri.queryParameters['disable-properties'],
    );

    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return AnimatedBuilder(
          animation: Listenable.merge([workbenchProvider, previewProvider]),
          builder: (BuildContext context, Widget? child) {
            return WidgetbookPage<CustomTheme>(
              disableNavigation: disableNavigation,
              disableProperties: disableProperties,
            );
          },
        );
      },
    );
  };
}

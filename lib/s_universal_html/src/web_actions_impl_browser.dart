import 'package:web/web.dart' as web;

void reloadWindow() => web.window.location.reload();

void navigateTo(String url) => web.window.location.assign(url);

void replaceLocation(String url) => web.window.location.replace(url);

String get currentHref => web.window.location.href;

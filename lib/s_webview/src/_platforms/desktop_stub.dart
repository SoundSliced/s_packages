/// Web stand-ins for the desktop platform declarations: no-ops, so the public
/// functions exist on every platform without pulling desktop code into web
/// builds.
library;

/// No-op on the web.
void initializeWindowsWebView() {}

/// No-op on the web.
void initializeMacOSWebView() {}

/// No-op on the web.
void initializeLinuxWebView() {}

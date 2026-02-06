# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## 1.0.1

- README updated


## 1.0.0 - 2026-01-13

### Added

- Initial release of `s_connectivity`.
- `AppInternetConnectivity` static API:
	- `initialiseInternetConnectivityListener(...)` to start listening.
	- `isConnected` synchronous getter.
	- `listenable` (`ValueListenable<bool>`) for UI state (recommended).
	- `emitCurrentStateNow()` to emit callbacks for the currently known state.
	- `hardReset()` to clear listeners/state (useful for Flutter Web hot restart).
	- `disposeInternetConnectivityListener()` to clean up.
- Ready-to-use offline UI widgets:
	- `NoInternetWidget` (small indicator widget).
	- `NoInternetConnectionPopup` (full-screen overlay).

### Notes

- `emitInitialStatus: true` emits the currently known state immediately; it does **not** perform an actual network probe.


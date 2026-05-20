## 4.8.0
- No breaking changes, but improved documentation and ensured all tap/double-tap/long-press logic is robust and consistent.
- `SBounceable` continues to support:
  - Single tap, double tap, and long press callbacks
  - Deferred single tap when double tap is present (prevents accidental single tap on double tap)
  - Haptic feedback option
  - Configurable bounce animation curve, duration, and scale
- All tests pass for tap/double-tap arbitration and animation behavior.

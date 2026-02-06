## 1.1.0

Major release with comprehensive new features:

**Core API Enhancements:**
* `PostFrame.run<T>()` - Advanced API with cancellation, timeout, diagnostics & generic return values
* `PostFrame.builder()` and `PostFrame.simpleBuilder()` - Declarative widget builders
* Original `PostFrame.postFrame()` retained (non-breaking)
* `PostFrameResult<T>` - Rich diagnostics (frames waited, passes, metric waits, controllers)

**Iteration & Timing:**
* `PostFrame.repeat()` - Per-frame iteration with optional max iterations, interval & cancellation
* `PostFrameRepeater` controller with iteration streams and done future

**Layout & Size Detection:**
* `PostFrame.onLayout()` - Await stable widget size using GlobalKey
* Configurable stability frames and timeout handling

**Task Management:**
* `PostFrame.queueRun()` - Serialized advanced post-frame tasks
* `PostFrame.clearQueue()` - Cancel pending queued tasks
* `PostFrame.debounced()` - Debounce rapid calls, cancel previous pending tasks

**Conditional Execution:**
* `predicate` parameter on `run()`, `debounced()`, and `queueRun()`
* `PostFramePredicates` helper class: `mounted()`, `stateMounted()`, `routeActive()`, `scrollControllerHasClients()`, `scrollExtentAtLeast()`, `all()`, `any()`, `not()`

**BuildContext Extensions:**
* `context.postFrame()` - Simple post-frame with automatic mounted check
* `context.postFrameRun<T>()` - Advanced with cancellation, timeout & mounted predicate
* `context.postFrameDebounced<T>()` - Debounced execution with mounted check
* `context.awaitLayout()` - Convenience wrapper for layout waiting

**Error Handling & Debugging:**
* Global `PostFrame.errorHandler` for all operations
* Per-call `onError` callback parameter
* Enhanced error propagation and diagnostics

**Testing & Documentation:**
* Comprehensive test suite (25 tests covering all features)
* Complete example app demonstrating all features
* README updated with usage examples for every feature
* Scroll metric stabilization improvements & clamp fix when `maxWaitFrames == 0`

## 1.0.2

* updated `README.md` file.


## 1.0.1

* Enhanced example folder with dynamic button interaction.
* Added a new test to verify `PostFrame.postFrame` waits for `ScrollController` metrics.
* Updated dependencies in `pubspec.yaml`.

## 1.0.0

* Initial public release.
* Provides `PostFrame.postFrame` utility to execute actions after the first frame is rendered.
* Supports waiting for end-of-frame and scroll controller metrics.
* Includes example and test files.

## 0.0.1

* Initial release

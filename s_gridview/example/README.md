# s_gridview Example

This example demonstrates a full-featured usage of the `s_gridview` package. It provides controls to:

- Toggle vertical/horizontal layout
- Change `crossAxisItemCount` (columns/rows)
- Toggle the scroll indicators and choose a color
- Programmatic scrolling using an injected `IndexedScrollController` (the "Scroll to #21" button)
- Set `autoScrollToIndex` at build-time (and see how out-of-bounds values are clamped)

Run:

```bash
cd example && flutter pub get
flutter run
```

Open the example app and use the visible controls to exercise all the `s_gridview` features interactively.

## 1.0.4 - 2025-11-29

- pubspec.yaml's package description updated

## 1.0.3 - 2025-11-29

- README updated: new screenshots (icon banners)

## 1.0.2 - 2025-11-29

- README updated

## 1.0.1

- README updated to show exmaple screenshots


## 1.0.0 - 2025-11-29

- Initial stable release.
- Adds `SBanner` widget: overlay ribbon with configurable position, color, elevation and custom content.
- Includes example usage and basic widget tests.
- Add visual example assets and more robust geometry/orientation tests.
- Support for circular child widgets via `isChildCircular` parameter.
- Banner shape adapts with curved edges to naturally wrap around circular children using quadratic Bezier curves and arcs.
- Semi-circular banners sit fully inside circular children and align their curved edge with the child's border radius.
- `childBorderRadius` parameter to override the detected radius when needed.
- Circular banners measure the child at runtime to adapt to any size changes automatically.
- Updated painter to draw smooth annular quadrants with thickness derived from the child's bounds.
- Add comprehensive test suite for circular child support.
- Update example app with circular child toggle option.
- Update README with circular child usage examples and tips.
- Initial prototype and experiments.

# s_banner

s_banner is a small Flutter package that renders an angular corner banner (a ribbon) attached to one of the four corners of a widget. It is built for simple overlays and supports custom content, color, elevation and corner clipping.

This package provides a single convenient widget, `SBanner`, which overlays a ribbon with custom content on top of another widget.

## Example

Open `example/lib/main.dart` to see a small demo. The example shows how to toggle the banner on and off and position it in different corners.

### Visual examples

Below are screenshots that demonstrate the ribbon applied to both rectangular and circular widgets in different corners.

#### Rectangular widgets

Without banner (inactive):

![Rectangular widget](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/rect.png)

With banner - top-right:

![Rectangular banner top-right](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/rect-tr.png)

With banner - bottom-left:

![Rectangular banner bottom-left](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/rect-bl.png)

#### Circular widgets

Without banner (inactive):

![Circular widget](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/circular.png)

With banner - top-left:

![Circular banner top-left](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/circular-tl.png)

With banner - bottom-right:

![Circular banner bottom-right](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/circular-br.png)


With Icon banner:

![Circular Icon banner bottom-left](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/circular-icon-bl.png)

![Circular Icon banner bottom-left](https://raw.githubusercontent.com/SoundSliced/s_banner/main/example/assets/rect-icon-tr.png)


## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  s_banner: ^1.0.4
```

If you are working locally with a path dependency for development, point to the package directory:

```yaml
dependencies:
  s_banner:
    path: ../
```

## Features

- Overlay a ribbon at any corner: top-left, top-right, bottom-left, bottom-right
- Custom widget for banner content (text, icons, badges, etc.)
- Configurable background color and elevation
- Optionally clip the banner to the child's bounds or allow it to overflow
- **New:** Support for circular child widgets with curved banner edges that naturally wrap around the circular shape

## API

`SBanner` exposes the following parameters:

- `bannerPosition` (SBannerPosition): Where to draw the banner (topLeft, topRight, bottomLeft, bottomRight). Defaults to `SBannerPosition.topLeft`.
- `bannerColor` (Color): Background color for the ribbon. Defaults to a green.
- `elevation` (double): The elevation of the banner to control shadow size. Defaults to 5.
- `shadowColor` (Color): Shadow color used by the banner's drop shadow.
- `bannerContent` (Widget): Custom widget rendered inside the banner ribbon (e.g., `Text`, `Icon`, or a `Chip`). Defaults to `Text('Banner')`.
- `child` (Widget): The required child widget to overlay the banner on.
- `isActive` (bool): Show/hide the banner (defaults to `true`). When `false`, it returns `child` directly.
- `clipBannerToChild` (bool): Whether the ribbon is clipped to the child's bounds. Defaults to `true`.
- `isChildCircular` (bool): Whether the child widget is circular. When `true`, the banner shape adapts with curved edges to naturally wrap around the circular child. Defaults to `false`.
- `childBorderRadius` (double?): Optional explicit radius when using circular banners. When omitted, the radius is inferred from the rendered child size, allowing the semi-circular banner to stay flush with the child's edge.

## Quick usage

The simplest example wraps the target widget and provides a text content for the ribbon:

```dart
import 'package:flutter/material.dart';
import 'package:s_banner/s_banner.dart';

class BannerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SBanner(
      bannerPosition: SBannerPosition.topRight,
      bannerContent: Text('NEW', style: TextStyle(color: Colors.white)),
      bannerColor: Colors.red,
      child: SizedBox(width: 200, height: 200, child: Placeholder()),
    );
  }
}
```

A complete runnable example lives in the `example/` directory and demonstrates several options.

### Custom content examples

You can use any widget as `bannerContent`. Here are a few examples:

Badge-like text and icon:

```dart
SBanner(
  bannerPosition: SBannerPosition.topLeft,
  bannerContent: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star, size: 14, color: Colors.white),
      const SizedBox(width: 6),
      const Text('HOT', style: TextStyle(color: Colors.white)),
    ],
  ),
  bannerColor: Colors.deepOrange,
  child: Card(child: SizedBox(width: 150, height: 80)),
 )
```

Use an Icon alone:

```dart
SBanner(
  bannerContent: const Icon(Icons.local_offer, color: Colors.white),
  bannerColor: Colors.black,
  child: SizedBox(height: 120, width: 140),
);
```

Circular child with curved banner edges:

```dart
SBanner(
  bannerPosition: SBannerPosition.topRight,
  isChildCircular: true,
  childBorderRadius: 70, // optional override, otherwise auto-detected
  bannerContent: const Text('SALE', style: TextStyle(color: Colors.white)),
  bannerColor: Colors.red,
  child: Container(
    width: 150,
    height: 150,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.blue,
    ),
    child: Center(child: Icon(Icons.person, size: 60)),
  ),
);
```

Tips:
- If using multi-line text or large widgets for `bannerContent`, control size with a `SizedBox` or `Padding`.
- The banner rotates content 45 degrees; account for the visible area when sizing.
- When using `isChildCircular: true`, the banner edges will curve to follow the circular shape of the child widget, creating a more natural appearance that stays inside the child's bounds. Provide `childBorderRadius` if you need to override the automatically detected radius.


## Tests

This package contains a basic widget test that verifies the banner can be shown and hidden and that content is present in the widget tree.

### Geometry & orientation

Additional widget tests verify that the banner's content is placed in the correct corner of the target widget and that the internal banner render box size matches the expected calculation based on content width/height.

## License

This package is available under the MIT license. See `LICENSE` for details.

## Repository

https://github.com/SoundSliced/s_banner

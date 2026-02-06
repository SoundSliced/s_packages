## 1.1.0

* **BREAKING CHANGE**: Removed `glowRectFactor` parameter - now using single `glowRadiusFactor` for both circle and rectangle shapes
* Enhanced Glow2 animation to start from slightly inside widget borders using `startInsetFactor`
* Added `startInsetFactor` parameter to control where glow animation begins (default 0.1)
* Improved `glowRadiusFactor` behavior:
  - For circles: percentage of radius
  - For rectangles: percentage of half-width and half-height for more proportional expansion
* Changed animation tween to start at 0.1 instead of 0.0 for smoother visual effect
* Updated example app with interactive slider to adjust `glowRadiusFactor` in real-time
* Improved example layout with side-by-side comparison of Glow1 and Glow2
* Enhanced documentation with clearer parameter descriptions
* Fixed rectangle shape expansion calculation to use child's actual width and height

## 1.0.0

* Production-ready release
* Stable API for Glow1 and Glow2 widgets
* Added comprehensive documentation for Glow1 and Glow2 widgets
* Updated README with detailed usage examples
* Added MIT License
* Enhanced package description
* Added example implementations
* Added comprehensive test coverage

## 0.0.1

* Initial release

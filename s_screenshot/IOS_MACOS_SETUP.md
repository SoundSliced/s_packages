# iOS & macOS Configuration for s_screenshot

The `s_screenshot` package uses `file_saver` for cross-platform file downloads. To ensure proper functionality on iOS and macOS, please follow these configuration steps:

## iOS Configuration

### Option 1: Using Info.plist

1. Open `ios/Runner/Info.plist`
2. Add the following keys:

```xml
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
```

### Option 2: Using Xcode

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select the Runner project in the project navigator
3. In the info.plist editor, add these rows:
   - **Application supports iTunes file sharing** (Boolean) → **Yes**
   - **Supports opening documents in place** (Boolean) → **Yes**

---

## macOS Configuration

### Option 1: Using Entitlements Files

1. Navigate to `macos/Runner/`
2. Open `DebugProfile.entitlements` (for debug builds)
3. Add the following key:

```xml
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

4. Also edit `Release.entitlements` (for release builds) and add the same key

**Optional:** If you encounter `Client Socket Exception` errors when saving files from network links in macOS:

Add to both entitlements files:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

### Option 2: Using Xcode

1. Open Xcode: `open macos/Runner.xcworkspace`
2. Select the Runner project
3. Go to **Signing & Capabilities**
4. Add capabilities for:
   - **File Access** → Downloads Read/Write
   - **Network** → Client (if needed for remote file downloads)

---

## Verification

After making these changes:

1. Clean the build cache: `flutter clean`
2. Rebuild for iOS or macOS
3. Test the download functionality using the example app:
   ```bash
   flutter run -d <device_id>
   ```

---

## References

- [file_saver package documentation](https://pub.dev/packages/file_saver)
- [iOS file sharing configuration](https://developer.apple.com/documentation/uikit/view_controllers/providing_access_to_directories)
- [macOS entitlements reference](https://developer.apple.com/documentation/bundleresources/entitlements)

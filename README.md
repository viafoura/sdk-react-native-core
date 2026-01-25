# Viafoura Mobile React Native SDK Sample

Sample Expo app that demonstrates how to use the Viafoura Mobile React Native
SDK (`@viafoura/sdk-react-native`) in a real app flow.

# Requirements

- Node >= 20.19.4 (Expo SDK 54 / React Native 0.81)
- Expo CLI (via `npx expo`)

# Install

```
npm install
```

# Prebuild

Because this sample uses native modules, you need a prebuild before running
on device or simulator:

```
npx expo prebuild --clean
```

# Configure

Update the placeholders in `viafouraConfig.ts` with real Viafoura values:

- `siteUUID`
- `siteDomain`
- `containerId`
- `articleUrl`
- `articleTitle`
- `articleThumbnailUrl`

# Run

```
npm run start
```

```
npm run ios
```

```
npm run android
```

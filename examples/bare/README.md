# Viafoura React Native sample (bare)

A bare React Native app that consumes `@viafoura/sdk-react-native` from the
package at the repository root, so it always runs the source in this checkout.

## Run

Install and build the package first, from the repository root:

```
npm install
```

Then, in this directory:

```
npm install
cd ios && RCT_USE_RN_DEP=1 pod install && cd ..
npm run ios
npm run android
```

`npm run start` starts Metro on its own. Metro watches the repository root, so
edits under `src/` reload without reinstalling; native changes under `ios/` or
`android/` need a rebuild.

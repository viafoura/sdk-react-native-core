# Viafoura React Native sample (bare)

A bare React Native app that consumes `@viafoura/sdk-react-native` from the
package at the repository root, so it always runs the source in this checkout.

## What it demonstrates

| Screen | Shows |
| --- | --- |
| Article list | Entry points for two articles and a Live Q&A session |
| Article | `ConversationStarterView` above `PreviewCommentsView`, both sized from `onHeightChanged`, with React-rendered ads (`renderAd`), `colors`, `fonts`, a dark-mode switch driving `theme`, and `onAction` logging |
| Live Q&A | `LiveQuestionsView` sized from `onHeightChanged`, with the native composer and `onAction` logging |
| Profile, New comment | `ProfileView` and `NewCommentView`, reached only on Android (iOS presents them natively) |
| Login, Sign up, Forgot password | `Viafoura.login`, `Viafoura.signup`, `Viafoura.resetPassword` |

`src/customUI.ts` runs at startup and shows `ViafouraCustomUI`: hiding the
"powered by" footers, rounding the starter button, restyling the Live Q&A title
and host pill, and a per-theme text colour on comment author names using both
the iOS and Android view-type names.

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

## Configure

Site, domain, colours and the demo articles live in `src/viafoura.ts`; fonts in
`src/fonts.ts`.

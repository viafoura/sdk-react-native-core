# @viafoura/sdk-react-native

The Viafoura SDK for React Native. Ships the native iOS and Android SDKs, so there
are no native files to copy into your app.

## Requirements

| | |
| --- | --- |
| React Native | 0.81+ (verified on 0.81.5) |
| Architecture | New architecture (Fabric) and the legacy bridge |
| iOS | 13.0+, Xcode 16+ |
| Android | minSdk 24, compileSdk 35 |

Expo Go is not supported: the package contains native code, so it needs a
development build.

## Install

This is a standard React Native module. It autolinks in **bare React Native apps**
and in **Expo apps that run prebuild** — there is one package and one integration
path for both.

```
npm install @viafoura/sdk-react-native
```

### Bare React Native

```
cd ios && RCT_USE_RN_DEP=1 pod install
```

`RCT_USE_RN_DEP=1` makes CocoaPods use React Native's prebuilt dependency
artifacts. Without it, CocoaPods compiles `fmt` 11.0.2 (pinned by `RCT-Folly`)
from source, which fails under Xcode 26. You can put it in your `Podfile`
instead so nobody has to remember it:

```ruby
ENV['RCT_USE_RN_DEP'] ||= '1'
```

Android needs nothing beyond `npm install` — Gradle autolinking registers
`ViafouraPackage` for you.

### Expo

```
npx expo prebuild
```

Prebuild already uses the prebuilt dependency artifacts, so no extra flag is
needed. No config plugin is required, and nothing goes in `app.json`.

### Removing a direct ViafouraCore dependency

If your `Podfile` has `pod 'ViafouraCore'`, delete it. This package vendors the
same `ViafouraSDK.xcframework`, and CocoaPods refuses to install both:

```
[!] The '<YourApp>' target has frameworks with conflicting names: viafourasdk.xcframework.
```

## Platform support

| Export | iOS | Android |
| --- | --- | --- |
| `Viafoura` (auth, initialize) | yes | yes |
| `PreviewCommentsView` | yes | yes |
| `ConversationStarterView` | yes | yes |
| `LiveQuestionsView` | yes | yes |
| `ViafouraAdSlot` | yes | yes |
| `ViafouraCustomUI` | yes | yes |
| `ProfileView` | renders empty | yes |
| `NewCommentView` | renders empty | yes |

## Auth API

All methods return a promise and reject with an `Error` on failure.

```ts
import Viafoura from '@viafoura/sdk-react-native';

await Viafoura.initialize(siteUUID, siteDomain, enableLogging?);
await Viafoura.login(email, password);
await Viafoura.signup(name, email, password);
await Viafoura.socialLogin(token, provider?);
await Viafoura.loginRadiusLogin(token, provider?);
await Viafoura.openIdLogin(token);
await Viafoura.cookieLogin(token);
await Viafoura.resetPassword(email);
await Viafoura.logout();
```

`initialize` is idempotent for the same site. Calling it again with a different
`siteUUID`/`siteDomain` rejects.

## Custom UI

```ts
import { ViafouraCustomUI } from '@viafoura/sdk-react-native';

ViafouraCustomUI.setCustomUIStyle(viewType, { visibility, backgroundColor }, theme?);
ViafouraCustomUI.clearCustomUIStyle(viewType, theme?);
```

## Usage

Initialize the SDK once at app startup (e.g., in `App.tsx` or a bootstrap module):

```ts
import Viafoura from '@viafoura/sdk-react-native';

await Viafoura.initialize('SITE_UUID', 'your.domain.com', true);
```

Then render the views you need:

```tsx
import { PreviewCommentsView } from '@viafoura/sdk-react-native';

<PreviewCommentsView
  containerId="YOUR_CONTAINER_ID"
  articleUrl="https://example.com/article"
  articleTitle="Title"
  articleThumbnailUrl="https://example.com/thumb.jpg"
/>
```

The engagement starter (`ConversationStarterView`) works on both platforms and reports its
own height:

```tsx
import { ConversationStarterView } from '@viafoura/sdk-react-native';

<ConversationStarterView
  containerId="YOUR_CONTAINER_ID"
  articleUrl="https://example.com/article"
  articleTitle="Title"
  articleThumbnailUrl="https://example.com/thumb.jpg"
  style={{ height }}
  onHeightChanged={({ nativeEvent }) => setHeight(nativeEvent.newHeight)}
  onSeeMoreComments={() => openComments()}
/>
```

`ProfileView` and `NewCommentView` are Android-only. On iOS they render as empty views.

## Live Q&A

`LiveQuestionsView` renders a live question-and-answer session for a container. It
works on both platforms and reports its own height.

```tsx
import { LiveQuestionsView } from '@viafoura/sdk-react-native';

<LiveQuestionsView
  containerId="YOUR_CONTAINER_ID"
  articleUrl="https://example.com/article"
  articleTitle="Title"
  articleThumbnailUrl="https://example.com/thumb.jpg"
  title="Live Q&A"
  style={{ height }}
  onHeightChanged={({ nativeEvent }) => setHeight(nativeEvent.newHeight)}
  onAuthNeeded={() => navigateToLogin()}
  onOpenProfile={({ nativeEvent }) => openProfile(nativeEvent.userUUID)}
/>
```

| Prop | Default | Meaning |
| --- | --- | --- |
| `containerId` | — | Required. The container the session belongs to. |
| `articleUrl`, `articleTitle`, `articleThumbnailUrl` | — | Required article metadata. |
| `articleSubtitle` | `''` | Optional article metadata. |
| `authorId` | — | Optional author identifier. |
| `title` | SDK default | Heading shown above the session. |
| `sectionUUID` | — | Scopes the session to a section. Must be a UUID. |
| `focusedContentUUID` | — | Opens with this question focused. Must be a UUID. |
| `limit` | `10` | Questions fetched per page. |
| `replyLimit` | `2` | Replies fetched per question. |
| `darkMode` / `theme` | `light` | `theme` wins when both are set. |
| `colors` | SDK defaults | Same shape as the other views. |

Events: `onHeightChanged`, `onAuthNeeded`, `onOpenProfile`, and `onAction` for the
full action stream.

Props are read when the session is created, so changing `containerId`,
`sectionUUID`, `limit` or `replyLimit` later has no effect until the view
remounts. `darkMode` and `theme` do apply live.

## Ads

`PreviewCommentsView` can interleave ads into the comment list. Ads are rendered by React,
so you can use any ad component you already have — `react-native-google-mobile-ads`, a house
ad, or anything else.

Pass `renderAd` plus an `adInterval`:

```tsx
import { PreviewCommentsView } from '@viafoura/sdk-react-native';
import { BannerAd, BannerAdSize } from 'react-native-google-mobile-ads';

<PreviewCommentsView
  containerId="YOUR_CONTAINER_ID"
  articleUrl="https://example.com/article"
  articleTitle="Title"
  articleThumbnailUrl="https://example.com/thumb.jpg"
  adInterval={5}
  firstAdPosition={3}
  adHeight={250}
  renderAd={({ position }) => (
    <BannerAd unitId={MY_AD_UNIT} size={BannerAdSize.MEDIUM_RECTANGLE} />
  )}
/>
```

| Prop | Default | Meaning |
| --- | --- | --- |
| `adInterval` | `0` | Comments between ads. `0` disables ads entirely. |
| `firstAdPosition` | `2` | How many comments to show before the first ad. |
| `adHeight` | `250` | Height in dp/points reserved for each ad. |
| `renderAd` | — | Returns the React element for a given slot. Ads are off unless this is set. |
| `onAdSlotRequested` | — | Fires when the native list opens a new ad slot. |

`adInterval` and `firstAdPosition` are read once when the comment list is created, so changing
them later has no effect until the view remounts.

Each ad is requested by the native list, which emits `onAdSlotRequested` and then hosts the
React element you return from `renderAd`. Because the element is mounted after the native row
exists, the row starts at zero height and grows to `adHeight` once your ad is attached — set
`adHeight` to your ad's real height to avoid a visible reflow.

Ad impressions are reported through the Viafoura analytics already built into the native SDKs.

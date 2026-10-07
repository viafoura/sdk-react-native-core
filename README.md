# @viafoura/sdk-react-native

The Viafoura SDK for React Native. It wraps the native iOS and Android SDKs as
React Native views and modules, so there are no native files to copy into your
app.

| Bundled native SDK | Version |
| --- | --- |
| iOS `ViafouraSDK.xcframework` | 1.3.12 |
| Android `com.viafoura:android` | 2.1.16 |

## Contents

- [Requirements](#requirements)
- [Install](#install)
- [Quick start](#quick-start)
- [Platform support](#platform-support)
- [Authentication](#authentication)
- [Views](#views)
  - [Shared props](#shared-props)
  - [PreviewCommentsView](#previewcommentsview)
  - [ConversationStarterView](#conversationstarterview)
  - [LiveQuestionsView](#livequestionsview)
  - [ProfileView](#profileview-android-only)
  - [NewCommentView](#newcommentview-android-only)
- [Action events](#action-events)
- [Theming](#theming)
- [Custom UI](#custom-ui)
- [Ads](#ads)
- [Sample apps](#sample-apps)
- [Development](#development)

## Requirements

| | |
| --- | --- |
| React Native | 0.81+ (verified on 0.81.5) |
| Architecture | New architecture (Fabric, through the interop layer) and the legacy bridge |
| iOS | 13.0+, Xcode 16+ |
| Android | minSdk 24, compileSdk 35 |

Expo Go is not supported: the package contains native code, so it needs a
development build.

## Install

This is a standard React Native module. It autolinks in **bare React Native apps**
and in **Expo apps that run prebuild**. There is one package and one integration
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

Android needs nothing beyond `npm install`. Gradle autolinking registers
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

## Quick start

Initialize once at startup, then render a view. Every view reports its own
height through `onHeightChanged`, so the usual pattern is to keep the height in
state and place the view inside your article's `ScrollView`:

```tsx
import { useEffect, useState } from 'react';
import { ScrollView } from 'react-native';
import Viafoura, { PreviewCommentsView } from '@viafoura/sdk-react-native';

export function Article() {
  const [height, setHeight] = useState(400);

  useEffect(() => {
    Viafoura.initialize('SITE_UUID', 'your.domain.com', __DEV__).catch(console.warn);
  }, []);

  return (
    <ScrollView>
      <PreviewCommentsView
        containerId="YOUR_CONTAINER_ID"
        articleUrl="https://example.com/article"
        articleTitle="Title"
        articleThumbnailUrl="https://example.com/thumb.jpg"
        style={{ height }}
        onHeightChanged={({ nativeEvent }) => setHeight(nativeEvent.newHeight)}
        onAuthNeeded={() => navigation.navigate('Login')}
      />
    </ScrollView>
  );
}
```

`initialize` is idempotent for the same site. Calling it again with a different
`siteUUID`/`siteDomain` rejects.

## Platform support

| Export | iOS | Android |
| --- | --- | --- |
| `Viafoura` (initialize, auth) | yes | yes |
| `PreviewCommentsView` | yes | yes |
| `ConversationStarterView` | yes | yes |
| `LiveQuestionsView` | yes | yes |
| `ViafouraAdSlot` | yes | yes |
| `ViafouraCustomUI` | yes | yes |
| `ProfileView` | renders empty | yes |
| `NewCommentView` | renders empty | yes |

### Profiles and the comment composer differ per platform

When a user taps an avatar or "write a comment", the two platforms behave
differently, and your navigation code has to account for it:

- **iOS** presents the profile and the comment composer itself, as native modals
  on top of the current screen. It still emits `onOpenProfile` and
  `onNewComment` so you can track them, but if you also navigate on those events
  you will show the screen twice.
- **Android** only emits the events. Your app navigates to a screen that renders
  `ProfileView` or `NewCommentView`.

```tsx
import { Platform } from 'react-native';

<PreviewCommentsView
  {...articleProps}
  onOpenProfile={({ nativeEvent }) => {
    if (Platform.OS !== 'android') return;
    navigation.navigate('Profile', {
      userUUID: nativeEvent.userUUID,
      presentationType: nativeEvent.presentationType ?? 'profile',
    });
  }}
  onNewComment={({ nativeEvent }) => {
    if (Platform.OS !== 'android') return;
    navigation.navigate('NewComment', {
      newCommentActionType: nativeEvent.actionType ?? 'create',
      content: nativeEvent.content,
    });
  }}
/>
```

Login is the exception: neither platform ships a login screen. `onAuthNeeded`
fires on both and your app shows its own UI backed by the [auth API](#authentication).

## Authentication

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

A minimal login screen, as used by both sample apps:

```tsx
const [error, setError] = useState<string | null>(null);

async function submit() {
  try {
    await Viafoura.login(email, password);
    navigation.goBack();
  } catch (err) {
    setError(err instanceof Error ? err.message : String(err));
  }
}
```

The session lives in the native SDK, so there is no token to pass to the views.
Both sample apps simply navigate back once `login` resolves.

## Views

### Shared props

Every view takes these. Article metadata identifies the page the comments belong
to and is required wherever it appears.

| Prop | Type | Meaning |
| --- | --- | --- |
| `containerId` | `string` | Required. The Viafoura container. |
| `articleUrl`, `articleTitle`, `articleThumbnailUrl` | `string` | Required article metadata. |
| `articleSubtitle` | `string` | Optional article metadata. |
| `syndicationKey` | `string` | Shares one conversation across several articles. Not on `LiveQuestionsView`. |
| `darkMode` | `boolean` | Legacy theme switch. `theme` wins when both are set. |
| `theme` | `'light' \| 'dark'` | See [Theming](#theming). Applies live. |
| `colors` | `ViafouraColors` | Primary colours. See [Colors](#colors). |
| `fonts` | `ViafouraFonts` | Font family per weight. See [Fonts](#fonts). |
| `style` | `ViewStyle` | Give the view a `height`; see `onHeightChanged`. |
| `onHeightChanged` | event | `{ newHeight, containerId }`. Fires whenever the native content height changes. |
| `onAuthNeeded` | event | `{ requireLogin }`. The user tried something that needs an account. |
| `onAction` | event | Every native action as one stream. See [Action events](#action-events). |

Props that configure the native session (`containerId`, article metadata,
`syndicationKey`, `colors`, `fonts`, `limit`, `adInterval` and the like) are
read once when the native view is created. Changing them later has no effect
until the view remounts; give the view a `key` if you need to swap containers.
`theme` and `darkMode` are the exception and apply live.

### PreviewCommentsView

The comment list for an article: header, sort control, comment cells with
replies, "see more" and the trending carousel. Both platforms.

```tsx
import { PreviewCommentsView } from '@viafoura/sdk-react-native';

<PreviewCommentsView
  containerId="YOUR_CONTAINER_ID"
  articleUrl="https://example.com/article"
  articleTitle="Title"
  articleSubtitle="Subtitle"
  articleThumbnailUrl="https://example.com/thumb.jpg"
  authorId="AUTHOR_ID"
  theme="light"
  colors={{ colorPrimary: '#1D5EFF', colorPrimaryLight: '#E8F0FF' }}
  style={{ height }}
  onHeightChanged={({ nativeEvent }) => setHeight(nativeEvent.newHeight)}
  onAuthNeeded={() => navigation.navigate('Login')}
  onOpenProfile={openProfile}
  onNewComment={openNewComment}
  onArticlePressed={({ nativeEvent }) => openArticle(nativeEvent.articleUrl)}
  onAction={({ nativeEvent }) => console.log(nativeEvent)}
/>
```

| Prop | Default | Meaning |
| --- | --- | --- |
| `authorId` | — | Marks comments by this user with the author badge. |
| `adInterval`, `firstAdPosition`, `adHeight`, `renderAd`, `onAdSlotRequested` | ads off | See [Ads](#ads). |

| Event | Payload | Fires when |
| --- | --- | --- |
| `onOpenProfile` | `{ userUUID, presentationType }` | An avatar or name is tapped. `presentationType` is `profile` or `feed`. |
| `onNewComment` | `{ actionType, content }` | Android: the composer should open; `actionType` is `create`, `edit` or `reply` and `content` the UUID being edited or replied to. iOS: a comment was posted; `content` is the new comment's UUID. |
| `onArticlePressed` | `{ articleUrl, containerId }` | A trending article is tapped. |

### ConversationStarterView

A compact engagement prompt: a headline, a featured comment and a call to
action. Place it above the article body or wherever you want to pull readers
into the conversation. Both platforms.

```tsx
import { ConversationStarterView } from '@viafoura/sdk-react-native';

<ConversationStarterView
  containerId="YOUR_CONTAINER_ID"
  articleUrl="https://example.com/article"
  articleTitle="Title"
  articleThumbnailUrl="https://example.com/thumb.jpg"
  title="Join the conversation"
  description="Tell us what you think."
  minimumCommentCount={3}
  style={{ height }}
  onHeightChanged={({ nativeEvent }) => setHeight(nativeEvent.newHeight)}
  onSeeMoreComments={() => scrollToComments()}
  onAuthNeeded={() => navigation.navigate('Login')}
  onOpenProfile={openProfile}
  onNewComment={openNewComment}
/>
```

| Prop | Default | Meaning |
| --- | --- | --- |
| `title` | SDK default | Headline. |
| `description` | SDK default | Body text under the headline. |
| `minimumCommentCount` | SDK default | Hide the featured comment until the container has this many comments. |

Events: `onSeeMoreComments` (the call to action), `onOpenProfile`,
`onNewComment` and `onAction`. Start it at `height: 0` and let `onHeightChanged`
grow it, so the starter takes no space until it has content.

### LiveQuestionsView

A live question-and-answer session for a container. Both platforms.

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
  onAction={({ nativeEvent }) => console.log(nativeEvent)}
/>
```

| Prop | Default | Meaning |
| --- | --- | --- |
| `authorId` | — | Optional author identifier. |
| `title` | SDK default | Heading shown above the session. |
| `sectionUUID` | — | Scopes the session to a section. Must be a UUID. |
| `focusedContentUUID` | — | Opens with this question focused. Must be a UUID. |
| `limit` | `10` | Questions fetched per page. |
| `replyLimit` | `2` | Replies fetched per question. |

Events: `onHeightChanged`, `onAuthNeeded`, `onOpenProfile`, and `onAction`.

#### Composer

Asking a question, replying, or answering opens the SDK's Live Q&A composer. The
view presents it natively on both platforms (a modal on iOS, a bottom sheet on
Android) using the same `colors`, `fonts`, `theme`, and `sectionUUID` as the
session, so there is nothing to wire up. There is no separate composer component.

Before the composer opens, `onAction` fires with `type: 'writeNewQuestionPressed'`
and an `actionType` of `question`, `reply`, or `answer`. For replies and answers
`content` carries the UUID of the question being responded to. Actions the
composer reports while open, such as `authPressed` when a guest tries to post,
are forwarded through the same `onAction` and `onAuthNeeded` callbacks. When a
post succeeds, `onAction` fires with `type: 'commentPosted'` for a new question
or `type: 'replyPosted'` for a reply or answer, and `content` carries the UUID of
the posted content on both platforms.

### ProfileView (Android only)

The user profile and activity feed. On iOS this component renders nothing,
because the iOS SDK presents the profile itself (see
[Profiles and the comment composer](#profiles-and-the-comment-composer-differ-per-platform)).

```tsx
import { ProfileView } from '@viafoura/sdk-react-native';

<ProfileView
  style={{ flex: 1 }}
  userUUID={route.params.userUUID}
  presentationType={route.params.presentationType}
  onCloseProfile={() => navigation.goBack()}
  onAuthNeeded={() => navigation.navigate('Login')}
/>
```

| Prop | Default | Meaning |
| --- | --- | --- |
| `userUUID` | — | Required. The user to show. |
| `presentationType` | `profile` | `profile` or `feed`. |

Events: `onCloseProfile`, `onAuthNeeded`, `onAction`. The view fills whatever
height you give it; it does not report its own.

### NewCommentView (Android only)

The comment composer. On iOS this component renders nothing, because the iOS SDK
presents the composer itself.

```tsx
import { NewCommentView } from '@viafoura/sdk-react-native';

<NewCommentView
  style={{ flex: 1 }}
  containerId={article.containerId}
  articleUrl={article.articleUrl}
  articleTitle={article.articleTitle}
  articleThumbnailUrl={article.articleThumbnailUrl}
  newCommentActionType={route.params.newCommentActionType}
  content={route.params.content}
  onCloseNewComment={() => navigation.goBack()}
  onAuthNeeded={() => navigation.navigate('Login')}
/>
```

| Prop | Default | Meaning |
| --- | --- | --- |
| `newCommentActionType` | — | Required. `create`, `edit` or `reply`, straight from `onNewComment`. |
| `content` | — | UUID of the comment being edited or replied to. |

Events: `onCloseNewComment`, `onHeightChanged`, `onAuthNeeded`, `onAction`.
`onAction` fires with `commentPosted` or `replyPosted` when the user posts.

## Action events

`onAction` is the raw stream of everything the native SDK reports. The dedicated
callbacks (`onOpenProfile`, `onNewComment`, …) are conveniences layered on top of
it; use `onAction` for analytics or for the events that have no dedicated
callback. `nativeEvent.type` discriminates the payload (`ActionCallbackPayload`
in TypeScript):

| `type` | Extra fields | Meaning |
| --- | --- | --- |
| `writeNewCommentPressed` | `actionType` (`create`/`edit`/`reply`), `content` | Comment composer requested. |
| `writeNewQuestionPressed` | `actionType` (`question`/`reply`/`answer`), `content` | Live Q&A composer requested. |
| `openProfilePressed` | `userUUID`, `presentationType` | Profile requested. |
| `seeMoreCommentsPressed` | — | "See more comments" tapped. |
| `trendingArticlePressed` | `containerId`, `articleUrl` | Trending article tapped. |
| `notificationPressed` | `presentationType` (`profile`/`content`), `userUUID`, `containerUUID`, `contentUUID`, `containerId`, `articleUrl` | A notification was tapped inside the profile. |
| `commentPosted`, `replyPosted` | `content` (new UUID) | Posted from a composer. |
| `commentLiked`, `commentDisliked` | `content` | Reaction in the conversation starter. |
| `authPressed` | `requireLogin` | Login or signup needed. Also fires `onAuthNeeded`. |
| `closeNewCommentPressed`, `closeProfilePressed` | — | Android: the user closed the composer or profile. |

## Theming

### Light and dark

Pass `theme="light"` or `theme="dark"`. `darkMode` is the older boolean form;
`theme` wins when both are set. Both apply live without a remount, so you can
bind them to `useColorScheme()`:

```tsx
import { useColorScheme } from 'react-native';

const theme = useColorScheme() === 'dark' ? 'dark' : 'light';
<PreviewCommentsView {...articleProps} theme={theme} />
```

### Colors

`colors` sets the accent colours the SDK uses everywhere: buttons, links, active
states and the avatar palette. Keys you leave out keep the SDK defaults.

```tsx
<PreviewCommentsView
  {...articleProps}
  colors={{
    colorPrimary: '#1D5EFF',
    colorPrimaryLight: '#E8F0FF',
    colorAvatars: sixteenHexColours,
  }}
/>
```

| Key | Meaning |
| --- | --- |
| `colorPrimary` | Main accent. |
| `colorPrimaryLight` | Tint used for highlights and selected backgrounds. |
| `colorAvatars` | Background colours for generated avatars. Must contain exactly as many entries as the SDK's default palette (16), otherwise it is ignored. |

Colours are `#RRGGBB` or `#AARRGGBB` strings. `colors` is read when the native
view is created.

### Fonts

Every view accepts a `fonts` prop. Each key names the font the SDK uses for that
weight; keys you leave out keep the SDK's bundled Inter fonts.

```tsx
<PreviewCommentsView
  {...articleProps}
  fonts={{
    fontLight: 'Lora-Regular',
    fontRegular: 'Lora-Regular',
    fontMedium: 'Lora-Medium',
    fontSemibold: 'Lora-SemiBold',
    fontBold: 'Lora-Bold',
  }}
/>
```

Values follow the same convention as React Native's own `fontFamily`: the
PostScript name on iOS, and the file name under `assets/fonts/` (`.ttf` or
`.otf`) on Android. Fonts are bundled by the host app, not by this package.
Bare React Native apps list the directory in `react-native.config.js` under
`assets` and run `npx react-native-asset`; Expo apps use the `expo-font` config
plugin. Both sample apps bundle Lora this way; Lora is licensed under the SIL
Open Font License and its `OFL.txt` sits next to the font files.

Fonts control the family per weight only. Text sizes stay as the SDK defines
them for each label; use [Custom UI](#custom-ui) to change the size of a specific
label. A name that does not resolve at runtime falls back to the SDK default for
that weight. Like `colors`, `fonts` is read when the native view is created.

## Custom UI

`ViafouraCustomUI` restyles or hides individual native views inside the SDK's
screens: the "powered by" footer, a separator, the author's name label, the host
pill in Live Q&A, and so on. It is global state: set a style once at startup and
every view created afterwards picks it up.

```ts
import { CustomUITheme, CustomUIViewType, ViafouraCustomUI } from '@viafoura/sdk-react-native';

ViafouraCustomUI.setCustomUIStyle(viewType, style, theme?);
ViafouraCustomUI.clearCustomUIStyle(viewType, theme?);
```

### Style properties

| Property | Type | Applies to | Notes |
| --- | --- | --- | --- |
| `visibility` | `'visible' \| 'hidden'` | any view | `GONE` on Android, so the view leaves the layout. `isHidden` on iOS, which keeps the view's frame unless it sits in a stack view, so a hidden view can leave blank space. |
| `backgroundColor` | `#RRGGBB` / `#AARRGGBB` | any view | |
| `textColor` | colour | labels, text inputs, buttons | |
| `tintColor` | colour | image views | Icons are recoloured. On iOS it also sets `tintColor` on any view. |
| `fontFamily` | `string` | labels, text inputs, buttons | Same naming as [Fonts](#fonts). Keeps the current size unless `fontSize` is also set. |
| `fontSize` | `number` | labels, text inputs, buttons | Points on iOS, sp on Android. |
| `cornerRadius` | `number` | any view | Points / dp. Clips the view's content. |
| `borderColor` | colour | any view | |
| `borderWidth` | `number` | any view | Points / dp. Defaults to 1 when only `borderColor` is set. |
| `opacity` | `number` | any view | `0` to `1`. |

On Android, `cornerRadius`, `borderColor` and `borderWidth` replace the view's
background with a shape drawable. A solid background colour the SDK had set is
kept; a custom drawable is not, so pass `backgroundColor` alongside them when
the result matters.

### Examples

Hide the "powered by" footers. The comments footer has a different name per
platform, so set both; `CustomUIViewType` contains the union:

```ts
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.previewPoweredByView, { visibility: 'hidden' });
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.previewPoweredBy, { visibility: 'hidden' });
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.liveQuestionPoweredByView, { visibility: 'hidden' });
```

Round the conversation starter's button and give it an outline:

```ts
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.conversationStarterActionButton, {
  cornerRadius: 20,
  borderWidth: 1,
  borderColor: '#1D5EFF',
});
```

Change the Live Q&A heading's font and size, and recolour the host pill:

```ts
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.liveQuestionTitleLabel, {
  fontFamily: 'Lora-Bold',
  fontSize: 22,
});
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.liveQuestionCellHostPillView, {
  backgroundColor: '#1D5EFF',
  cornerRadius: 10,
});
```

Different text colour per theme. A style set with a theme applies only to views
rendered in that theme; a style set without one is the fallback for both:

```ts
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.commentCellNameLabel, { textColor: '#1D5EFF' }, CustomUITheme.Light);
ViafouraCustomUI.setCustomUIStyle(CustomUIViewType.commentCellNameLabel, { textColor: '#8AB4FF' }, CustomUITheme.Dark);
```

### How styles are applied

- **Timing.** The SDK asks for a view's style when it creates or binds that view.
  Call `setCustomUIStyle` before the first Viafoura view mounts, at module scope
  or in your app bootstrap. A style set later applies to views created after
  that point (new cells as the user scrolls, or a remounted view), not to views
  already on screen.
- **Merging.** Calling `setCustomUIStyle` again for the same view type and theme
  merges the new properties over the old ones. Use `clearCustomUIStyle` to
  remove a style entirely.
- **Themes.** The lookup is `viewType + theme` first, then `viewType` without a
  theme. `clearCustomUIStyle(viewType)` clears only the unthemed entry; pass the
  theme to clear a themed one.
- **Scope.** Styles apply inside every Viafoura view in the app, including the
  profile and comment composer the iOS SDK presents on its own.

### View types

`CustomUIViewType` lists every customizable view in the bundled SDKs, grouped by
prefix:

| Prefix | Area |
| --- | --- |
| `preview*`, `commentCell*` | `PreviewCommentsView`: header, sort control, comment cells, URL previews, separators, footer |
| `conversationStarter*` | `ConversationStarterView` |
| `liveQuestion*`, `liveQuestions*` | `LiveQuestionsView`: question cells, host list, inline prompt, header, status chip |
| `post*`, `writeReply*` | Comment composer |
| `profile*`, `userCell*`, `userComment*` | Profile and its activity lists |
| `report*`, `bottomPicker*` | Report flow and the bottom sheet picker |
| `trending*` | Trending carousel and vertical list |
| `notification*` | Notification bell and list |
| `poll*` | Polls |
| `chat*` | Live chat |

iOS and Android name some views differently. Labels usually end in `Label` on
iOS and `Text` on Android (`commentCellNameLabel` vs `commentCellUserText`,
`previewTitleLabel` vs `previewTitleText`), and a few views exist on one platform
only (`liveQuestionsHostCellBadgePillView` and
`liveQuestionsHostsListBackgroundView` are iOS only; `previewCounterText` and
`profileMainTabText` are Android only). `IOSCustomUIViewType` and
`AndroidCustomUIViewType` list each platform on its own; `CustomUIViewType` is
their union. Setting a name the current platform does not use is a no-op, so
setting both names is the simplest way to stay portable.

What cannot be customized this way: the Live Q&A composer sheet, because
neither native SDK exposes a customization hook for it. It does follow `colors`,
`fonts` and `theme`.

## Ads

`PreviewCommentsView` can interleave ads into the comment list. Ads are rendered by React,
so you can use any ad component you already have: `react-native-google-mobile-ads`, a house
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
exists, the row starts at zero height and grows to `adHeight` once your ad is attached. Set
`adHeight` to your ad's real height to avoid a visible reflow.

Ad impressions are reported through the Viafoura analytics already built into the native SDKs.
Both sample apps render a house ad this way (`HouseAd.tsx`).

## Sample apps

Two sample apps live in this repository and consume the package from source.
Run `npm install` at the repository root first, then follow the README in the
sample's directory.

| | |
| --- | --- |
| [`examples/bare`](examples/bare) | Bare React Native app (React Native CLI) |
| [`examples/expo`](examples/expo) | Expo app using prebuild |

Both cover the same surface: `PreviewCommentsView` with ads, colours, fonts and a
dark-mode switch; `ConversationStarterView`; `LiveQuestionsView` with the native
composer; `ProfileView` and `NewCommentView` on Android; login, signup and
password reset; and a `customUI.ts` that exercises `ViafouraCustomUI`.

## Development

```
npm install        # builds build/ and fetches the iOS xcframework
npm run build      # tsc
npm run lint       # eslint src
```

There is no JavaScript test suite; `npm test` is a placeholder. CI (`.github/workflows/build.yml`)
lints and builds the TypeScript, then packs the module and installs the tarball
into both sample apps and compiles each for Android and iOS, so the published
artifact is what gets smoke-tested.

Native SDK APIs should be checked against the shipped binaries rather than older
code: `javap` on the Android AAR in the Gradle cache, and the `.swiftinterface`
inside `ios/ViafouraSDK.xcframework`. The custom UI view type lists in
`src/Viafoura.types.ts` and the switch in `ios/CustomUIViewResolver.swift` mirror
those binaries exactly and need updating when the native SDK versions change.

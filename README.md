# @viafoura/sdk-react-native

Basic install and usage.

# Install

```
npm install @viafoura/sdk-react-native
```

iOS:

```
npx pod-install
```

# Usage

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

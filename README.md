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

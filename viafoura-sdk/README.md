# viafoura-sdk

My new module

# API documentation

- [Documentation for the latest stable release](https://docs.expo.dev/versions/latest/sdk/viafoura-sdk/)
- [Documentation for the main branch](https://docs.expo.dev/versions/unversioned/sdk/viafoura-sdk/)

# Installation in managed Expo projects

For [managed](https://docs.expo.dev/archive/managed-vs-bare/) Expo projects, please follow the installation instructions in the [API documentation for the latest stable release](#api-documentation). If you follow the link and there is no documentation available then this library is not yet usable within managed projects &mdash; it is likely to be included in an upcoming Expo SDK release.

# Installation in bare React Native projects

For bare React Native projects, you must ensure that you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

### Add the package to your npm dependencies

```
npm install viafoura-sdk
```

### Configure for Android




### Configure for iOS

Run `npx pod-install` after installing the npm package.

# Usage

Initialize the SDK once at app startup (e.g., in `App.tsx` or a bootstrap module):

```ts
import Viafoura from 'viafoura-sdk';

await Viafoura.initialize('SITE_UUID', 'your.domain.com', true);
```

Then render the views you need:

```tsx
import { PreviewCommentsView } from 'viafoura-sdk';

<PreviewCommentsView
  containerId="YOUR_CONTAINER_ID"
  articleUrl="https://example.com/article"
  articleTitle="Title"
  articleThumbnailUrl="https://example.com/thumb.jpg"
/>
```

`ProfileView` and `NewCommentView` are Android-only. On iOS they render as empty views.

# Contributing

Contributions are very welcome! Please refer to guidelines described in the [contributing guide]( https://github.com/expo/expo#contributing).

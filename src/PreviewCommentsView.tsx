import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { PreviewCommentsViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<PreviewCommentsViewProps> =
  requireNativeViewManager('PreviewComments');

export default function PreviewCommentsView(props: PreviewCommentsViewProps) {
  return <NativeView {...props} />;
}

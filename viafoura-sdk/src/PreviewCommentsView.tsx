import { requireNativeView } from 'expo';
import * as React from 'react';

import { PreviewCommentsViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<PreviewCommentsViewProps> =
  requireNativeView('PreviewComments');

export default function PreviewCommentsView(props: PreviewCommentsViewProps) {
  return <NativeView {...props} />;
}


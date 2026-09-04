import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ConversationStarterViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<ConversationStarterViewProps> =
  requireNativeViewManager('ConversationStarter');

export default function ConversationStarterView(props: ConversationStarterViewProps) {
  return <NativeView {...props} />;
}

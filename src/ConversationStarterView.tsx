import { requireNativeComponent } from 'react-native';
import * as React from 'react';

import { ConversationStarterViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<ConversationStarterViewProps> =
  requireNativeComponent('ConversationStarter');

export default function ConversationStarterView(props: ConversationStarterViewProps) {
  return <NativeView {...props} />;
}

import { requireNativeComponent } from 'react-native';
import * as React from 'react';

import { NativeViewProps, toNativeEventProps } from './nativeEvents';
import { ConversationStarterViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<NativeViewProps> = requireNativeComponent('ConversationStarter');

export default function ConversationStarterView(props: ConversationStarterViewProps) {
  return <NativeView {...toNativeEventProps(props)} />;
}

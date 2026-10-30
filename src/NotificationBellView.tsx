import * as React from 'react';
import { requireNativeComponent } from 'react-native';

import { NativeViewProps, toNativeEventProps } from './nativeEvents';
import { NotificationBellViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<NativeViewProps> = requireNativeComponent('ViafouraNotificationBell');

export default function NotificationBellView(props: NotificationBellViewProps) {
  return <NativeView {...toNativeEventProps(props)} />;
}

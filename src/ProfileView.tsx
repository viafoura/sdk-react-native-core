import * as React from 'react';
import { Platform, requireNativeComponent } from 'react-native';

import { NativeViewProps, toNativeEventProps } from './nativeEvents';
import { ProfileViewProps } from './Viafoura.types';

function ProfileFallbackView(_props: NativeViewProps) {
  return null;
}

const NativeView: React.ComponentType<NativeViewProps> =
  Platform.OS === 'android' ? requireNativeComponent('Profile') : ProfileFallbackView;

export default function ProfileView(props: ProfileViewProps) {
  return <NativeView {...toNativeEventProps(props)} />;
}

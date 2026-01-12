import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';
import { Platform } from 'react-native';

import { ProfileViewProps } from './Viafoura.types';

function ProfileFallbackView(_props: ProfileViewProps) {
  return null;
}

const NativeView: React.ComponentType<ProfileViewProps> =
  Platform.OS === 'android'
    ? requireNativeViewManager('Profile')
    : ProfileFallbackView;

export default function ProfileView(props: ProfileViewProps) {
  return <NativeView {...props} />;
}

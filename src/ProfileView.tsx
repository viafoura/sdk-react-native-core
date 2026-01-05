import { requireNativeView } from 'expo';
import * as React from 'react';
import { Platform, View } from 'react-native';

import { ProfileViewProps } from './Viafoura.types';

function ProfileFallbackView({ style }: ProfileViewProps) {
  return <View style={style} />;
}

const NativeView: React.ComponentType<ProfileViewProps> =
  Platform.OS === 'android'
    ? requireNativeView('Profile')
    : ProfileFallbackView;

export default function ProfileView(props: ProfileViewProps) {
  return <NativeView {...props} />;
}

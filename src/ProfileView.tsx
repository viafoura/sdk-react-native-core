import * as React from 'react';
import { Platform, requireNativeComponent } from 'react-native';

import { ProfileViewProps } from './Viafoura.types';

function ProfileFallbackView(_props: ProfileViewProps) {
  return null;
}

const NativeView: React.ComponentType<ProfileViewProps> =
  Platform.OS === 'android' ? requireNativeComponent('Profile') : ProfileFallbackView;

export default function ProfileView(props: ProfileViewProps) {
  return <NativeView {...props} />;
}

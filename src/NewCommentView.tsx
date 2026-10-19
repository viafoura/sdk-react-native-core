import * as React from 'react';
import { Platform, requireNativeComponent } from 'react-native';

import { NativeViewProps, toNativeEventProps } from './nativeEvents';
import { NewCommentViewProps } from './Viafoura.types';

function NewCommentFallbackView(_props: NativeViewProps) {
  return null;
}

const NativeView: React.ComponentType<NativeViewProps> =
  Platform.OS === 'android' ? requireNativeComponent('NewComment') : NewCommentFallbackView;

export default function NewCommentView(props: NewCommentViewProps) {
  return <NativeView {...toNativeEventProps(props)} />;
}

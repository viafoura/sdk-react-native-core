import * as React from 'react';
import { Platform, requireNativeComponent } from 'react-native';

import { NewCommentViewProps } from './Viafoura.types';

function NewCommentFallbackView(_props: NewCommentViewProps) {
  return null;
}

const NativeView: React.ComponentType<NewCommentViewProps> =
  Platform.OS === 'android' ? requireNativeComponent('NewComment') : NewCommentFallbackView;

export default function NewCommentView(props: NewCommentViewProps) {
  return <NativeView {...props} />;
}

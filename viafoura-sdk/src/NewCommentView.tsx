import { requireNativeView } from 'expo';
import * as React from 'react';
import { Platform, View } from 'react-native';

import { NewCommentViewProps } from './Viafoura.types';

function NewCommentFallbackView({ style }: NewCommentViewProps) {
  return <View style={style} />;
}

const NativeView: React.ComponentType<NewCommentViewProps> =
  Platform.OS === 'android'
    ? requireNativeView('NewComment')
    : NewCommentFallbackView;

export default function NewCommentView(props: NewCommentViewProps) {
  return <NativeView {...props} />;
}

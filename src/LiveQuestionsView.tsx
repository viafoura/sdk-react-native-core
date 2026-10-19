import * as React from 'react';
import { requireNativeComponent } from 'react-native';

import { NativeViewProps, toNativeEventProps } from './nativeEvents';
import { LiveQuestionsViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<NativeViewProps> = requireNativeComponent('LiveQuestions');

export default function LiveQuestionsView(props: LiveQuestionsViewProps) {
  return <NativeView {...toNativeEventProps(props)} />;
}

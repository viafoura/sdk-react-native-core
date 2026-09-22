import * as React from 'react';
import { requireNativeComponent } from 'react-native';

import { LiveQuestionsViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<LiveQuestionsViewProps> =
  requireNativeComponent('LiveQuestions');

export default function LiveQuestionsView(props: LiveQuestionsViewProps) {
  return <NativeView {...props} />;
}

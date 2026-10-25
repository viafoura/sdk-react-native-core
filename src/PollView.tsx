import * as React from 'react';
import { requireNativeComponent } from 'react-native';

import { NativeViewProps, toNativeEventProps } from './nativeEvents';
import { PollViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<NativeViewProps> = requireNativeComponent('ViafouraPoll');

export default function PollView(props: PollViewProps) {
  return <NativeView {...toNativeEventProps(props)} />;
}

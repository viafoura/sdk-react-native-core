import { requireNativeComponent } from 'react-native';
import * as React from 'react';
import type { StyleProp, ViewStyle } from 'react-native';

export type ViafouraAdSlotProps = {
  position: number;
  adHeight?: number;
  style?: StyleProp<ViewStyle>;
  children?: React.ReactNode;
};

const NativeAdSlotView: React.ComponentType<ViafouraAdSlotProps> =
  requireNativeComponent('ViafouraAdSlot');

export default NativeAdSlotView;

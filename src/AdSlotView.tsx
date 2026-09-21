import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';
import type { StyleProp, ViewStyle } from 'react-native';

export type ViafouraAdSlotProps = {
  position: number;
  adHeight?: number;
  style?: StyleProp<ViewStyle>;
  children?: React.ReactNode;
};

const NativeAdSlotView: React.ComponentType<ViafouraAdSlotProps> =
  requireNativeViewManager('ViafouraAdSlot');

export default NativeAdSlotView;

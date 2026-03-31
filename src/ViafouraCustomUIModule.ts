import { NativeModule, requireNativeModule } from 'expo-modules-core';

import { VFCustomUIStyle, VFCustomUIViewType, VFCustomUITheme } from './Viafoura.types';

declare class ViafouraCustomUIModule extends NativeModule {
  setCustomUIStyle(viewType: VFCustomUIViewType, style: VFCustomUIStyle, theme?: VFCustomUITheme): void;
  clearCustomUIStyle(viewType: VFCustomUIViewType, theme?: VFCustomUITheme): void;
}

export default requireNativeModule<ViafouraCustomUIModule>('ViafouraCustomUI');

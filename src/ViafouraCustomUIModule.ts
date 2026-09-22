import { NativeModules } from 'react-native';

import { VFCustomUIStyle, VFCustomUIViewType, VFCustomUITheme } from './Viafoura.types';

export interface ViafouraCustomUINativeModule {
  setCustomUIStyle(
    viewType: VFCustomUIViewType,
    style: VFCustomUIStyle,
    theme?: VFCustomUITheme
  ): void;
  clearCustomUIStyle(viewType: VFCustomUIViewType, theme?: VFCustomUITheme): void;
}

const ViafouraCustomUIModule: ViafouraCustomUINativeModule =
  NativeModules.ViafouraCustomUI ??
  new Proxy({} as ViafouraCustomUINativeModule, {
    get() {
      throw new Error(
        `The package '@viafoura/sdk-react-native' doesn't seem to be linked.`
      );
    },
  });

export default ViafouraCustomUIModule;

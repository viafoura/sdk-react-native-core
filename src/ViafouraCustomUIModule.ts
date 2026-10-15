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

interface NativeCustomUIModule {
  setCustomUIStyle(
    viewType: VFCustomUIViewType,
    style: VFCustomUIStyle,
    theme: VFCustomUITheme | null
  ): void;
  clearCustomUIStyle(viewType: VFCustomUIViewType, theme: VFCustomUITheme | null): void;
}

const nativeModule: NativeCustomUIModule =
  NativeModules.ViafouraCustomUI ??
  new Proxy({} as NativeCustomUIModule, {
    get() {
      throw new Error(
        `The package '@viafoura/sdk-react-native' doesn't seem to be linked.`
      );
    },
  });

// The new architecture's interop layer rejects calls whose argument count differs
// from the native signature, so optional trailing arguments are always sent as null.
const ViafouraCustomUIModule: ViafouraCustomUINativeModule = {
  setCustomUIStyle(viewType, style, theme) {
    nativeModule.setCustomUIStyle(viewType, style, theme ?? null);
  },
  clearCustomUIStyle(viewType, theme) {
    nativeModule.clearCustomUIStyle(viewType, theme ?? null);
  },
};

export default ViafouraCustomUIModule;

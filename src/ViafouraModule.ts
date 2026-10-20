import { NativeModules, Platform } from 'react-native';

import type { ViafouraLoginStatus } from './Viafoura.types';

const LINKING_ERROR =
  `The package '@viafoura/sdk-react-native' doesn't seem to be linked. Make sure:\n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

export interface ViafouraNativeModule {
  logout(): Promise<void>;
  login(email: string, password: string): Promise<void>;
  signup(name: string, email: string, password: string): Promise<void>;
  socialLogin(token: string, provider?: string): Promise<void>;
  loginRadiusLogin(token: string, provider?: string): Promise<void>;
  openIdLogin(token: string): Promise<void>;
  cookieLogin(token: string): Promise<void>;
  resetPassword(email: string): Promise<void>;
  getUserLoginStatus(): Promise<ViafouraLoginStatus>;
  initialize(
    siteUUID: string,
    siteDomain: string,
    enableLogging?: boolean
  ): Promise<void>;
  setDataTrackingEnabled(enabled: boolean): Promise<void>;
}

interface NativeViafouraModule
  extends Omit<ViafouraNativeModule, 'socialLogin' | 'loginRadiusLogin' | 'initialize'> {
  socialLogin(token: string, provider: string | null): Promise<void>;
  loginRadiusLogin(token: string, provider: string | null): Promise<void>;
  initialize(
    siteUUID: string,
    siteDomain: string,
    enableLogging: boolean
  ): Promise<void>;
}

const nativeModule: NativeViafouraModule =
  NativeModules.Viafoura ??
  new Proxy({} as NativeViafouraModule, {
    get() {
      throw new Error(LINKING_ERROR);
    },
  });

// The new architecture's interop layer rejects calls whose argument count differs
// from the native signature, so optional trailing arguments are always sent as null.
const ViafouraModule: ViafouraNativeModule = {
  logout: () => nativeModule.logout(),
  login: (email, password) => nativeModule.login(email, password),
  signup: (name, email, password) => nativeModule.signup(name, email, password),
  socialLogin: (token, provider) => nativeModule.socialLogin(token, provider ?? null),
  loginRadiusLogin: (token, provider) =>
    nativeModule.loginRadiusLogin(token, provider ?? null),
  openIdLogin: (token) => nativeModule.openIdLogin(token),
  cookieLogin: (token) => nativeModule.cookieLogin(token),
  resetPassword: (email) => nativeModule.resetPassword(email),
  getUserLoginStatus: () => nativeModule.getUserLoginStatus(),
  initialize: (siteUUID, siteDomain, enableLogging) =>
    nativeModule.initialize(siteUUID, siteDomain, enableLogging ?? false),
  setDataTrackingEnabled: (enabled) => nativeModule.setDataTrackingEnabled(enabled),
};

export default ViafouraModule;

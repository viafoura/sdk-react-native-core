import { NativeModules, Platform } from 'react-native';

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
  initialize(
    siteUUID: string,
    siteDomain: string,
    enableLogging?: boolean
  ): Promise<void>;
}

const ViafouraModule: ViafouraNativeModule =
  NativeModules.Viafoura ??
  new Proxy({} as ViafouraNativeModule, {
    get() {
      throw new Error(LINKING_ERROR);
    },
  });

export default ViafouraModule;

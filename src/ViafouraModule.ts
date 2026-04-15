import { NativeModule, requireNativeModule } from 'expo-modules-core';

import { ViafouraModuleEvents } from './Viafoura.types';

declare class ViafouraModule extends NativeModule<ViafouraModuleEvents> {
  logout(): Promise<void>;
  login(email: string, password: string): Promise<void>;
  signup(name: string, email: string, password: string): Promise<void>;
  socialLogin(token: string, provider?: string): Promise<void>;
  loginRadiusLogin(token: string, provider?: string): Promise<void>;
  openIdLogin(token: string): Promise<void>;
  cookieLogin(token: string): Promise<void>;
  resetPassword(email: string): Promise<void>;
  initialize(siteUUID: string, siteDomain: string, enableLogging?: boolean): Promise<void>;
}

export default requireNativeModule<ViafouraModule>('Viafoura');

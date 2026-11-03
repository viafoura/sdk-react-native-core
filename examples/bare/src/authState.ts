import { useSyncExternalStore } from 'react';
import Viafoura from '@viafoura/sdk-react-native';

let loggedIn = false;
const listeners = new Set<() => void>();

const subscribe = (listener: () => void) => {
  listeners.add(listener);
  return () => listeners.delete(listener);
};

export const setLoggedIn = (value: boolean) => {
  if (loggedIn === value) return;
  loggedIn = value;
  listeners.forEach((listener) => listener());
};

export const refreshLoginStatus = () =>
  Viafoura.getUserLoginStatus()
    .then((status) => setLoggedIn(status.isLoggedIn))
    .catch(() => setLoggedIn(false));

export const useLoggedIn = () => useSyncExternalStore(subscribe, () => loggedIn);

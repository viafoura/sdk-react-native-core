import { NativeModules, Platform } from 'react-native';

import type {
  ViafouraFollowPage,
  ViafouraLoginStatus,
  ViafouraNotification,
  ViafouraNotifications,
  ViafouraTrendingArticle,
  ViafouraTrendingOptions,
  ViafouraUser,
  ViafouraUserCommentsOptions,
  ViafouraUserCommentsPage,
  ViafouraUserStats,
} from './Viafoura.types';

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
  getCommentCount(containerId: string, syndicationKey?: string): Promise<number>;
  getTrendingArticles(options?: ViafouraTrendingOptions): Promise<ViafouraTrendingArticle[]>;
  getNewNotificationCount(): Promise<number>;
  getNotifications(): Promise<ViafouraNotifications>;
  markNotificationsRead(notificationUUIDs: string[]): Promise<void>;
  markNotificationsSeen(notificationUUIDs: string[]): Promise<void>;
  removeNotifications(notificationUUIDs: string[]): Promise<void>;
  getFollowers(page?: number): Promise<ViafouraFollowPage>;
  getFollowing(page?: number): Promise<ViafouraFollowPage>;
  getFollowerCount(userUUID: string): Promise<number>;
  isFollowingUser(userUUID: string): Promise<boolean>;
  followUser(userUUID: string): Promise<void>;
  unfollowUser(userUUID: string): Promise<void>;
  getUserInfo(userUUID: string): Promise<ViafouraUser>;
  getUserComments(
    userUUID: string,
    options?: ViafouraUserCommentsOptions
  ): Promise<ViafouraUserCommentsPage>;
  getUserStats(userUUID: string): Promise<ViafouraUserStats>;
}

const TRENDING_DEFAULTS = { limit: 5, trendWindow: 3, daysPublished: 7 };

interface NativeViafouraModule
  extends Omit<
    ViafouraNativeModule,
    | 'socialLogin'
    | 'loginRadiusLogin'
    | 'initialize'
    | 'getCommentCount'
    | 'getTrendingArticles'
    | 'getNotifications'
    | 'getFollowers'
    | 'getFollowing'
    | 'getUserComments'
  > {
  socialLogin(token: string, provider: string | null): Promise<void>;
  loginRadiusLogin(token: string, provider: string | null): Promise<void>;
  initialize(
    siteUUID: string,
    siteDomain: string,
    enableLogging: boolean
  ): Promise<void>;
  getCommentCount(containerId: string, syndicationKey: string | null): Promise<number>;
  getTrendingArticles(
    limit: number,
    trendWindow: number,
    daysPublished: number | null
  ): Promise<ViafouraTrendingArticle[]>;
  getNotifications(): Promise<RawNotifications>;
  getFollowers(page: number | null): Promise<ViafouraFollowPage>;
  getFollowing(page: number | null): Promise<ViafouraFollowPage>;
  getUserComments(
    userUUID: string,
    limit: number,
    startingFrom: string | null
  ): Promise<ViafouraUserCommentsPage>;
}

type RawNotification = Omit<ViafouraNotification, 'type'> & { type: string };
type RawNotifications = Omit<ViafouraNotifications, 'notifications'> & {
  notifications: RawNotification[];
};

const TOMBSTONE_TYPES = new Set(['reply_removed', 'answer_removed', 'reply_deleted', 'unknown']);
const CANCELLING_TYPES = new Set(['reply_removed', 'answer_removed']);
const CANCELLABLE_TYPES = new Set(['reply', 'answer']);

// Mirrors what both native notification lists show: tombstones are dropped, and a
// reply or answer whose content was later removed loses that event (and the whole
// group once no events are left).
function visibleNotifications(raw: RawNotification[]): ViafouraNotification[] {
  const removed = new Set(
    raw
      .filter((n) => CANCELLING_TYPES.has(n.type))
      .flatMap((n) => n.events.map((e) => e.contentUUID.toLowerCase()))
  );
  return raw.flatMap((n) => {
    if (TOMBSTONE_TYPES.has(n.type)) return [];
    if (!CANCELLABLE_TYPES.has(n.type)) return [n as ViafouraNotification];
    const events = n.events.filter((e) => !removed.has(e.contentUUID.toLowerCase()));
    return events.length > 0 ? [{ ...(n as ViafouraNotification), events }] : [];
  });
}

const USER_COMMENTS_DEFAULT_LIMIT = 10;

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
  getCommentCount: (containerId, syndicationKey) =>
    nativeModule.getCommentCount(containerId, syndicationKey ?? null),
  getTrendingArticles: (options) => {
    const { limit, trendWindow, daysPublished } = { ...TRENDING_DEFAULTS, ...options };
    return nativeModule.getTrendingArticles(
      limit,
      trendWindow,
      daysPublished > 0 ? daysPublished : null
    );
  },
  getNewNotificationCount: () => nativeModule.getNewNotificationCount(),
  getNotifications: async () => {
    const { notifications, broadcasts } = await nativeModule.getNotifications();
    return {
      notifications: visibleNotifications(notifications),
      broadcasts: broadcasts.filter((b) => (b.type as string) !== 'unknown'),
    };
  },
  markNotificationsRead: (uuids) => nativeModule.markNotificationsRead(uuids),
  markNotificationsSeen: (uuids) => nativeModule.markNotificationsSeen(uuids),
  removeNotifications: (uuids) => nativeModule.removeNotifications(uuids),
  getFollowers: (page) => nativeModule.getFollowers(page ?? null),
  getFollowing: (page) => nativeModule.getFollowing(page ?? null),
  getFollowerCount: (userUUID) => nativeModule.getFollowerCount(userUUID),
  isFollowingUser: (userUUID) => nativeModule.isFollowingUser(userUUID),
  followUser: (userUUID) => nativeModule.followUser(userUUID),
  unfollowUser: (userUUID) => nativeModule.unfollowUser(userUUID),
  getUserInfo: (userUUID) => nativeModule.getUserInfo(userUUID),
  getUserComments: (userUUID, options) =>
    nativeModule.getUserComments(
      userUUID,
      options?.limit ?? USER_COMMENTS_DEFAULT_LIMIT,
      options?.startingFrom ?? null
    ),
  getUserStats: (userUUID) => nativeModule.getUserStats(userUUID),
};

export default ViafouraModule;

const NATIVE_EVENT_PROP_PREFIX = 'onViafoura';

export const VIAFOURA_EVENT_PROPS: readonly string[] = [
  'onHeightChanged',
  'onAuthNeeded',
  'onOpenProfile',
  'onNewComment',
  'onSeeMoreComments',
  'onArticlePressed',
  'onAction',
  'onAdSlotRequested',
  'onCloseProfile',
  'onCloseNewComment',
];

export type NativeViewProps = Record<string, unknown>;

export function toNativeEventProps(props: object): NativeViewProps {
  const native: NativeViewProps = {};
  for (const [key, value] of Object.entries(props)) {
    const nativeKey = VIAFOURA_EVENT_PROPS.includes(key)
      ? NATIVE_EVENT_PROP_PREFIX + key.slice(2)
      : key;
    native[nativeKey] = value;
  }
  return native;
}

import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import NativeAdSlotView from './AdSlotView';
import { PreviewCommentsAdSlotRequestedPayload, PreviewCommentsViewProps } from './Viafoura.types';

const NativeView: React.ComponentType<any> = requireNativeViewManager('PreviewComments');

const DEFAULT_AD_HEIGHT = 250;
const DEFAULT_FIRST_AD_POSITION = 2;

export default function PreviewCommentsView({
  renderAd,
  adInterval = 0,
  firstAdPosition = DEFAULT_FIRST_AD_POSITION,
  adHeight = DEFAULT_AD_HEIGHT,
  onAdSlotRequested,
  ...props
}: PreviewCommentsViewProps) {
  const [slots, setSlots] = React.useState<number[]>([]);
  const adsEnabled = Boolean(renderAd) && adInterval > 0;

  React.useEffect(() => {
    if (!adsEnabled) {
      setSlots((previous) => (previous.length === 0 ? previous : []));
    }
  }, [adsEnabled]);

  const handleAdSlotRequested = React.useCallback(
    (event: { nativeEvent: PreviewCommentsAdSlotRequestedPayload }) => {
      const { position } = event.nativeEvent;
      if (typeof position === 'number') {
        setSlots((previous) => (previous.includes(position) ? previous : [...previous, position]));
      }
      onAdSlotRequested?.(event);
    },
    [onAdSlotRequested],
  );

  return (
    <NativeView
      {...props}
      adInterval={adsEnabled ? adInterval : 0}
      firstAdPosition={firstAdPosition}
      onAdSlotRequested={handleAdSlotRequested}
    >
      {adsEnabled
        ? slots.map((position) => (
            <NativeAdSlotView
              key={position}
              position={position}
              adHeight={adHeight}
              style={{ width: '100%', height: adHeight }}
            >
              {renderAd?.({ position })}
            </NativeAdSlotView>
          ))
        : null}
    </NativeView>
  );
}

import React from 'react';
import { Platform, StyleSheet } from 'react-native';
import { NotificationBellView } from '@viafoura/sdk-react-native';
import { Screens } from '../navigation/screens';
import { handleProfileAction, type Navigation } from '../navigation/notifications';
import { viafouraFonts } from '../fonts';
import { viafouraColors } from '../viafoura';

const styles = StyleSheet.create({
  bell: { width: 40, height: 40 },
});

const HeaderBell = ({ navigation }: { navigation: Navigation }) => (
  <NotificationBellView
    style={styles.bell}
    colors={viafouraColors}
    fonts={viafouraFonts}
    onBellPressed={({ nativeEvent }) => {
      if (Platform.OS !== 'android') return;
      navigation.navigate(Screens.Profile, {
        userUUID: nativeEvent.userUUID,
        presentationType: 'feed',
      });
    }}
    onAuthNeeded={() => navigation.navigate(Screens.Login)}
    onAction={({ nativeEvent }) => handleProfileAction(navigation, nativeEvent)}
  />
);

export default HeaderBell;

import { Platform, StyleSheet } from 'react-native';
import { NotificationBellView } from '@viafoura/sdk-react-native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';

import type { RootStackParamList } from '../navigation/types';
import { viafouraConfig } from '../viafouraConfig';
import { handleProfileAction } from '../notifications';

const styles = StyleSheet.create({
  bell: { width: 40, height: 40 },
});

type HeaderBellProps = {
  navigation: NativeStackNavigationProp<RootStackParamList, keyof RootStackParamList>;
};

export default function HeaderBell({ navigation }: HeaderBellProps) {
  return (
    <NotificationBellView
      style={styles.bell}
      colors={{ ...viafouraConfig.colors }}
      fonts={{ ...viafouraConfig.fonts }}
      onBellPressed={({ nativeEvent }) => {
        if (Platform.OS !== 'android') return;
        navigation.navigate('Profile', { userUUID: nativeEvent.userUUID, presentationType: 'feed' });
      }}
      onAuthNeeded={() => {
        navigation.navigate('Login', { reason: 'Sign in to see your notifications.' });
      }}
      onAction={(event) => handleProfileAction(navigation, event.nativeEvent)}
    />
  );
}

import { SafeAreaView, View } from 'react-native';
import { ProfileView } from '@viafoura/sdk-react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';

import type { RootStackParamList } from '../navigation/types';
import { styles } from '../styles';

type ProfileScreenProps = NativeStackScreenProps<RootStackParamList, 'Profile'>;

export default function ProfileScreen({ route, navigation }: ProfileScreenProps) {
  return (
    <SafeAreaView style={styles.containerNoPadding}>
      <View style={[styles.previewContainer, styles.previewContainerFlat]}>
        <ProfileView
          userUUID={route.params.userUUID}
          presentationType={route.params.presentationType}
          onAuthNeeded={() => {
            navigation.navigate('Login', { reason: 'Sign in to view profiles.' });
          }}
          onCloseProfile={() => {
            navigation.goBack();
          }}
          style={styles.preview}
        />
      </View>
    </SafeAreaView>
  );
}

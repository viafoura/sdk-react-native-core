import React from 'react';
import { ProfileView } from '@viafoura/sdk-react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Screens } from '../../navigation/screens';
import { StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: { height: '100%' },
});

const ProfileScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();

  return (
    <ProfileView
      style={styles.container}
      userUUID={route.params?.userUUID}
      presentationType={route.params?.presentationType}
      darkMode={false}
      onCloseProfile={() => {
        navigation.goBack();
      }}
      onAuthNeeded={() => {
        navigation.navigate(Screens.Login);
      }}
    />
  );
};

export default ProfileScreen;

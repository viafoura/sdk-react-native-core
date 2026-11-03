import { Linking, Platform } from 'react-native';
import type { ActionCallbackPayload } from '@viafoura/sdk-react-native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';

import type { RootStackParamList } from './navigation/types';
import { viafouraConfig } from './viafouraConfig';

type Navigation = NativeStackNavigationProp<RootStackParamList, keyof RootStackParamList>;

export function handleProfileAction(navigation: Navigation, event: ActionCallbackPayload) {
  if (event.type === 'trendingArticlePressed') {
    if (event.containerId === viafouraConfig.containerId) navigation.navigate('Comments');
    return;
  }
  if (event.type !== 'notificationPressed') return;
  switch (event.presentationType) {
    case 'content':
      if (event.containerId === viafouraConfig.containerId) navigation.navigate('Comments');
      return;
    case 'liveQuestions':
      if (event.containerId === viafouraConfig.liveQuestionsContainerId) {
        navigation.navigate('LiveQuestions', { focusedContentUUID: event.contentUUID });
      }
      return;
    case 'profile':
      if (Platform.OS === 'android' && event.userUUID) {
        navigation.push('Profile', { userUUID: event.userUUID, presentationType: 'profile' });
      }
      return;
    case 'url':
      if (event.url) Linking.openURL(event.url);
      return;
  }
}

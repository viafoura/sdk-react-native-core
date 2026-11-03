import { Linking, Platform } from 'react-native';
import type { ActionCallbackPayload } from '@viafoura/sdk-react-native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { ParamListBase } from '@react-navigation/native';
import { Screens } from './screens';
import { articles, liveQuestions } from '../viafoura';

export type Navigation = NativeStackNavigationProp<ParamListBase>;

export const handleProfileAction = (
  navigation: Navigation,
  event: ActionCallbackPayload,
) => {
  if (event.type === 'trendingArticlePressed') {
    const article = articles.find((a) => a.containerId === event.containerId);
    if (article) navigation.navigate(Screens.Article, article);
    return;
  }
  if (event.type !== 'notificationPressed') return;
  switch (event.presentationType) {
    case 'content': {
      const article = articles.find((a) => a.containerId === event.containerId);
      if (article) navigation.navigate(Screens.Article, article);
      return;
    }
    case 'liveQuestions':
      if (event.containerId === liveQuestions.containerId) {
        navigation.navigate(Screens.LiveQuestions, {
          ...liveQuestions,
          focusedContentUUID: event.contentUUID,
        });
      }
      return;
    case 'profile':
      if (Platform.OS === 'android' && event.userUUID) {
        navigation.push(Screens.Profile, {
          userUUID: event.userUUID,
          presentationType: 'profile',
        });
      }
      return;
    case 'url':
      if (event.url) Linking.openURL(event.url);
      return;
  }
};

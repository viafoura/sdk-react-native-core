import React from 'react';
import { Platform, useWindowDimensions } from 'react-native';

import RNLiveQuestionsiOSComponent from '../../native/ios/RNLiveQuestionsiOS.js';
import RNLiveQuestionsAndroidComponent from '../../native/android/RNLiveQuestionsAndroid.js';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Screens } from '../../navigation/screens';

const LiveQuestions: any = Platform.select({
  ios: RNLiveQuestionsiOSComponent,
  android: RNLiveQuestionsAndroidComponent,
});

const LiveQuestionsScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  let height = useWindowDimensions().height - 100;

  return (
    <LiveQuestions
      style={{ height: height }}
      containerId={route.params.containerId}
      authorId={route.params.authorId}
      articleTitle={route.params.articleTitle}
      articleSubtitle={route.params.articleDesc}
      articleUrl={route.params.articleUrl}
      articleThumbnailUrl={route.params.articleThumbnailUrl}
      title={route.params.title}
      sectionUUID={route.params.sectionUUID}
      darkMode={false}
      onOpenProfile={(event: any) => {
        var object = {
          userUUID: event.userUUID,
          presentationType: event.presentationType ?? 'profile',
        };
        navigation.navigate(Screens.Profile, object);
      }}
      onAuthNeeded={() => {
        navigation.navigate(Screens.Login);
      }}
    />
  );
};

export default LiveQuestionsScreen;

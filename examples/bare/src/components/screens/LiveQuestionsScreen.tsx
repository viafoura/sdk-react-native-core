import React from 'react';
import { useWindowDimensions } from 'react-native';

import { LiveQuestionsView } from '@viafoura/sdk-react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Screens } from '../../navigation/screens';

const LiveQuestionsScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  let height = useWindowDimensions().height - 100;

  return (
    <LiveQuestionsView
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
      onOpenProfile={({ nativeEvent }) => {
        navigation.navigate(Screens.Profile, {
          userUUID: nativeEvent.userUUID,
          presentationType: nativeEvent.presentationType ?? 'profile',
        });
      }}
      onAuthNeeded={() => {
        navigation.navigate(Screens.Login);
      }}
    />
  );
};

export default LiveQuestionsScreen;

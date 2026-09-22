import React from 'react';
import { ScrollView } from 'react-native';
import { useState } from 'react';

import { PreviewCommentsView } from '@viafoura/sdk-react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Screens } from '../../navigation/screens';

const ArticleScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const [commentsHeight, setCommentsHeight] = useState(2000);

  return (
    <ScrollView style={{ height: commentsHeight }}>
      <PreviewCommentsView
        style={{ height: commentsHeight }}
        containerId={route.params.containerId}
        authorId={route.params.authorId}
        syndicationKey={route.params.syndicationKey}
        articleTitle={route.params.articleTitle}
        articleSubtitle={route.params.articleDesc}
        articleUrl={route.params.articleUrl}
        articleThumbnailUrl={route.params.articleThumbnailUrl}
        darkMode={false}
        onHeightChanged={({ nativeEvent }) => {
          if (nativeEvent.containerId === route.params.containerId) {
            setCommentsHeight(nativeEvent.newHeight);
          }
        }}
        onOpenProfile={({ nativeEvent }) => {
          navigation.navigate(Screens.Profile, {
            userUUID: nativeEvent.userUUID,
            presentationType: nativeEvent.presentationType ?? 'profile',
          });
        }}
        onArticlePressed={() => {
          navigation.push(Screens.Article, route.params);
        }}
        onNewComment={({ nativeEvent }) => {
          navigation.navigate(Screens.NewComment, {
            containerId: route.params.containerId,
            articleTitle: route.params.articleTitle,
            articleDesc: route.params.articleDesc,
            articleUrl: route.params.articleUrl,
            articleThumbnailUrl: route.params.articleThumbnailUrl,
            newCommentActionType: nativeEvent.actionType,
            content: nativeEvent.content,
          });
        }}
        onAuthNeeded={() => {
          navigation.navigate(Screens.Login);
        }}
      />
    </ScrollView>
  );
};

export default ArticleScreen;

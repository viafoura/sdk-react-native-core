import React, { useState } from 'react';
import { Platform, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';

import {
  ConversationStarterView,
  PreviewCommentsView,
} from '@viafoura/sdk-react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Screens } from '../../navigation/screens';
import { viafouraFonts } from '../../fonts';
import { viafouraColors } from '../../viafoura';
import HouseAd, { HOUSE_AD_HEIGHT } from '../HouseAd';

const styles = StyleSheet.create({
  light: { flex: 1, backgroundColor: '#FFFFFF' },
  dark: { flex: 1, backgroundColor: '#121212' },
  header: { padding: 16 },
  title: { fontSize: 22, fontWeight: '600' },
  subtitle: { fontSize: 15, marginTop: 8, lineHeight: 21 },
  lightText: { color: '#1B2430' },
  darkText: { color: '#F2F4F7' },
  switchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 12,
  },
});

const ArticleScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const [darkMode, setDarkMode] = useState(false);
  const [starterHeight, setStarterHeight] = useState(0);
  const [commentsHeight, setCommentsHeight] = useState(600);

  const article = route.params;
  const theme = darkMode ? 'dark' : 'light';
  const textStyle = darkMode ? styles.darkText : styles.lightText;

  const articleProps = {
    containerId: article.containerId,
    articleTitle: article.articleTitle,
    articleSubtitle: article.articleDesc,
    articleUrl: article.articleUrl,
    articleThumbnailUrl: article.articleThumbnailUrl,
    syndicationKey: article.syndicationKey,
    theme,
    colors: viafouraColors,
    fonts: viafouraFonts,
  } as const;

  const openProfile = ({ nativeEvent }) => {
    if (Platform.OS !== 'android') return;
    navigation.navigate(Screens.Profile, {
      userUUID: nativeEvent.userUUID,
      presentationType: nativeEvent.presentationType ?? 'profile',
    });
  };

  const openNewComment = ({ nativeEvent }) => {
    if (Platform.OS !== 'android') return;
    navigation.navigate(Screens.NewComment, {
      ...article,
      newCommentActionType: nativeEvent.actionType ?? 'create',
      content: nativeEvent.content,
    });
  };

  const openLogin = () => navigation.navigate(Screens.Login);

  return (
    <ScrollView style={darkMode ? styles.dark : styles.light}>
      <View style={styles.header}>
        <Text style={[styles.title, textStyle]}>{article.articleTitle}</Text>
        <Text style={[styles.subtitle, textStyle]}>{article.articleDesc}</Text>
        <View style={styles.switchRow}>
          <Text style={textStyle}>Dark mode</Text>
          <Switch value={darkMode} onValueChange={setDarkMode} />
        </View>
      </View>

      <ConversationStarterView
        {...articleProps}
        style={{ height: starterHeight }}
        onHeightChanged={({ nativeEvent }) =>
          setStarterHeight(nativeEvent.newHeight)
        }
        onSeeMoreComments={() => console.log('See more comments')}
        onOpenProfile={openProfile}
        onNewComment={openNewComment}
        onAuthNeeded={openLogin}
        onAction={({ nativeEvent }) =>
          console.log('ConversationStarter action', nativeEvent)
        }
      />

      <PreviewCommentsView
        {...articleProps}
        authorId={article.authorId}
        style={{ height: commentsHeight }}
        adInterval={4}
        firstAdPosition={2}
        adHeight={HOUSE_AD_HEIGHT}
        renderAd={({ position }) => <HouseAd position={position} />}
        onHeightChanged={({ nativeEvent }) => {
          if (nativeEvent.containerId === article.containerId) {
            setCommentsHeight(nativeEvent.newHeight);
          }
        }}
        onOpenProfile={openProfile}
        onNewComment={openNewComment}
        onArticlePressed={({ nativeEvent }) =>
          console.log('Trending article pressed', nativeEvent)
        }
        onAuthNeeded={openLogin}
        onAction={({ nativeEvent }) =>
          console.log('PreviewComments action', nativeEvent)
        }
      />
    </ScrollView>
  );
};

export default ArticleScreen;

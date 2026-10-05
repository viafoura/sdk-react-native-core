import { useState } from 'react';
import {
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  Switch,
  Text,
  View,
} from 'react-native';
import {
  ConversationStarterView,
  PreviewCommentsView,
  type ActionCallbackPayload,
  type PreviewCommentsNewCommentPayload,
  type PreviewCommentsOpenProfilePayload,
} from '@viafoura/sdk-react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';

import type { RootStackParamList } from '../navigation/types';
import { viafouraConfig } from '../viafouraConfig';
import { styles } from '../styles';
import HouseAd, { HOUSE_AD_HEIGHT } from '../components/HouseAd';

type CommentsScreenProps =
  NativeStackScreenProps<RootStackParamList, 'Comments'> & {
    initError: string | null;
  };

export default function CommentsScreen({ initError, navigation }: CommentsScreenProps) {
  const [darkMode, setDarkMode] = useState(false);
  const [starterHeight, setStarterHeight] = useState<number>(0);
  const [commentsHeight, setCommentsHeight] = useState<number>(260);

  const theme = darkMode ? 'dark' : 'light';
  const textStyle = darkMode ? styles.darkText : styles.lightText;

  const articleProps = {
    containerId: viafouraConfig.containerId,
    articleUrl: viafouraConfig.articleUrl,
    articleTitle: viafouraConfig.articleTitle,
    articleThumbnailUrl: viafouraConfig.articleThumbnailUrl,
    colors: { ...viafouraConfig.colors },
    fonts: { ...viafouraConfig.fonts },
    theme,
  } as const;

  const openLogin = () => {
    navigation.navigate('Login', { reason: 'Sign in to comment.' });
  };

  const openNewComment = (event: { nativeEvent: PreviewCommentsNewCommentPayload }) => {
    if (Platform.OS !== 'android') return;
    const actionType = event.nativeEvent?.actionType;
    navigation.navigate('NewComment', {
      actionType: actionType === 'edit' || actionType === 'reply' ? actionType : 'create',
      content: event.nativeEvent?.content,
    });
  };

  const openProfile = (event: { nativeEvent: PreviewCommentsOpenProfilePayload }) => {
    if (Platform.OS !== 'android') return;
    const userUUID = event.nativeEvent?.userUUID;
    if (!userUUID) return;
    navigation.navigate('Profile', {
      userUUID,
      presentationType: event.nativeEvent?.presentationType === 'feed' ? 'feed' : 'profile',
    });
  };

  const logAction = (source: string) => (event: { nativeEvent: ActionCallbackPayload }) => {
    console.log(`${source} action`, event.nativeEvent);
  };

  return (
    <SafeAreaView style={darkMode ? styles.containerDark : styles.containerNoPadding}>
      <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
        <View style={styles.articleContent}>
          <Text style={[styles.title, textStyle]}>
            The future of community engagement: why conversation design matters
          </Text>
          <Text style={[styles.subtitle, textStyle]}>
            From real-time chats to thoughtful comment threads, audiences expect
            more than a simple input box. This long-form teaser simulates an
            article intro so you can preview how the Viafoura module behaves
            when content spans multiple lines across different screen sizes and
            orientations, with enough copy to wrap and scroll naturally.
          </Text>
          <View style={styles.toolbar}>
            <View style={styles.switchRow}>
              <Text style={textStyle}>Dark mode</Text>
              <Switch value={darkMode} onValueChange={setDarkMode} />
            </View>
            <Pressable
              style={styles.actionButton}
              onPress={() => navigation.navigate('LiveQuestions')}
            >
              <Text style={styles.actionButtonText}>Open Live Q&A</Text>
            </Pressable>
          </View>
        </View>
        {initError ? (
          <Text style={styles.error}>Init error: {initError}</Text>
        ) : null}

        <ConversationStarterView
          {...articleProps}
          style={{ height: starterHeight }}
          onHeightChanged={(event) => {
            const next = event.nativeEvent?.newHeight;
            if (typeof next === 'number' && next >= 0) setStarterHeight(next);
          }}
          onSeeMoreComments={() => console.log('See more comments')}
          onAuthNeeded={openLogin}
          onNewComment={openNewComment}
          onOpenProfile={openProfile}
          onAction={logAction('ConversationStarter')}
        />

        <View style={[styles.previewContainer, styles.previewContainerFlat, { height: commentsHeight }]}>
          <PreviewCommentsView
            {...articleProps}
            adInterval={4}
            firstAdPosition={2}
            adHeight={HOUSE_AD_HEIGHT}
            renderAd={({ position }) => <HouseAd position={position} />}
            onHeightChanged={(event) => {
              const next = event.nativeEvent?.newHeight;
              if (typeof next === 'number' && next > 0) setCommentsHeight(next);
            }}
            onAuthNeeded={openLogin}
            onNewComment={openNewComment}
            onOpenProfile={openProfile}
            onArticlePressed={(event) => {
              console.log('Article pressed', event.nativeEvent);
            }}
            onAction={logAction('PreviewComments')}
            style={styles.preview}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

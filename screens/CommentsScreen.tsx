import { useState } from 'react';
import { Platform, SafeAreaView, ScrollView, Text, View } from 'react-native';
import { PreviewCommentsView } from '@viafoura/sdk-react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';

import type { RootStackParamList } from '../navigation/types';
import { viafouraConfig } from '../viafouraConfig';
import { styles } from '../styles';

type CommentsScreenProps =
  NativeStackScreenProps<RootStackParamList, 'Comments'> & {
    initError: string | null;
  };

export default function CommentsScreen({ initError, navigation }: CommentsScreenProps) {
  const [height, setHeight] = useState<number>(260);

  return (
    <SafeAreaView style={styles.containerNoPadding}>
      <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
        <View style={styles.articleContent}>
          <Text style={styles.title}>
            The future of community engagement: why conversation design matters
          </Text>
          <Text style={styles.subtitle}>
            From real-time chats to thoughtful comment threads, audiences expect
            more than a simple input box. This long-form teaser simulates an
            article intro so you can preview how the Viafoura module behaves
            when content spans multiple lines across different screen sizes and
            orientations, with enough copy to wrap and scroll naturally.
          </Text>
          <Text style={styles.subtitle}>
            In practice, a good community experience balances identity,
            moderation, and discovery. It surfaces the best contributions
            without hiding the long tail of conversation, and it helps authors
            understand how their stories resonate. Strong interaction design
            turns casual readers into returning members and gives publishers
            signal they can act on—faster.
          </Text>
          <Text style={styles.subtitle}>
            This sample content intentionally runs long to stress the layout and
            scrolling behavior. It helps validate spacing, typography, and how
            the comments preview integrates with the rest of the article. Swap
            this text with your real article body once you are ready.
          </Text>
        </View>
        {initError ? (
          <Text style={styles.error}>Init error: {initError}</Text>
        ) : null}
        <View style={[styles.previewContainer, styles.previewContainerFlat, { height }]}>
          <PreviewCommentsView
            containerId={viafouraConfig.containerId}
            articleUrl={viafouraConfig.articleUrl}
            articleTitle={viafouraConfig.articleTitle}
            articleThumbnailUrl={viafouraConfig.articleThumbnailUrl}
            onHeightChanged={(event) => {
              const next = event.nativeEvent?.newHeight;
              if (typeof next === 'number' && next > 0) setHeight(next);
            }}
          onAuthNeeded={() => {
            navigation.navigate('Login', { reason: 'Sign in to comment.' });
          }}
          onNewComment={(event) => {
            if (Platform.OS !== 'android') return;
            const actionType = event.nativeEvent?.actionType;
            const nextActionType =
              actionType === 'edit' || actionType === 'reply'
                ? actionType
                  : 'create';
              navigation.navigate('NewComment', {
                actionType: nextActionType,
                content: event.nativeEvent?.content,
              });
            }}
          onOpenProfile={(event) => {
            if (Platform.OS !== 'android') return;
            const userUUID = event.nativeEvent?.userUUID;
            if (!userUUID) return;
            navigation.navigate('Profile', {
                userUUID,
                presentationType:
                  event.nativeEvent?.presentationType === 'feed'
                    ? 'feed'
                    : 'profile',
              });
            }}
            onArticlePressed={(event) => {
              console.log('Article pressed', event.nativeEvent);
            }}
            style={styles.preview}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

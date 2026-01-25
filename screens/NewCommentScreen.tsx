import { useState } from 'react';
import { SafeAreaView, View } from 'react-native';
import { NewCommentView } from '@viafoura/sdk-react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';

import type { RootStackParamList } from '../navigation/types';
import { viafouraConfig } from '../viafouraConfig';
import { styles } from '../styles';

type NewCommentScreenProps = NativeStackScreenProps<RootStackParamList, 'NewComment'>;

export default function NewCommentScreen({ route, navigation }: NewCommentScreenProps) {
  const [height, setHeight] = useState<number>(320);

  return (
    <SafeAreaView style={styles.containerNoPadding}>
      <View style={[styles.previewContainer, styles.previewContainerFlat, { height }]}>
        <NewCommentView
          newCommentActionType={route.params.actionType}
          content={route.params.content}
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
          onCloseNewComment={() => {
            navigation.goBack();
          }}
          style={styles.preview}
        />
      </View>
    </SafeAreaView>
  );
}

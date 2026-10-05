import { useState } from 'react';
import { Platform, SafeAreaView, ScrollView, Switch, Text, View } from 'react-native';
import { LiveQuestionsView } from '@viafoura/sdk-react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';

import type { RootStackParamList } from '../navigation/types';
import { viafouraConfig } from '../viafouraConfig';
import { styles } from '../styles';

type LiveQuestionsScreenProps = NativeStackScreenProps<RootStackParamList, 'LiveQuestions'>;

export default function LiveQuestionsScreen({ navigation }: LiveQuestionsScreenProps) {
  const [darkMode, setDarkMode] = useState(false);
  const [height, setHeight] = useState<number>(600);

  return (
    <SafeAreaView style={darkMode ? styles.containerDark : styles.containerNoPadding}>
      <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
        <View style={[styles.articleContent, styles.switchRow]}>
          <Text style={darkMode ? styles.darkText : styles.lightText}>Dark mode</Text>
          <Switch value={darkMode} onValueChange={setDarkMode} />
        </View>
        <LiveQuestionsView
          containerId={viafouraConfig.liveQuestionsContainerId}
          articleUrl={viafouraConfig.articleUrl}
          articleTitle={viafouraConfig.articleTitle}
          articleThumbnailUrl={viafouraConfig.articleThumbnailUrl}
          title={viafouraConfig.liveQuestionsTitle}
          theme={darkMode ? 'dark' : 'light'}
          colors={{ ...viafouraConfig.colors }}
          fonts={{ ...viafouraConfig.fonts }}
          style={{ height }}
          onHeightChanged={(event) => {
            const next = event.nativeEvent?.newHeight;
            if (typeof next === 'number' && next > 0) setHeight(next);
          }}
          onAuthNeeded={() => {
            navigation.navigate('Login', { reason: 'Sign in to ask a question.' });
          }}
          onOpenProfile={(event) => {
            if (Platform.OS !== 'android') return;
            const userUUID = event.nativeEvent?.userUUID;
            if (!userUUID) return;
            navigation.navigate('Profile', {
              userUUID,
              presentationType: event.nativeEvent?.presentationType === 'feed' ? 'feed' : 'profile',
            });
          }}
          onAction={(event) => {
            console.log('LiveQuestions action', event.nativeEvent);
          }}
        />
      </ScrollView>
    </SafeAreaView>
  );
}

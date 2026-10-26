import { useState } from 'react';
import { SafeAreaView, ScrollView, Switch, Text, View } from 'react-native';
import { PollView } from '@viafoura/sdk-react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';

import type { RootStackParamList } from '../navigation/types';
import { viafouraConfig } from '../viafouraConfig';
import { styles } from '../styles';

type PollScreenProps = NativeStackScreenProps<RootStackParamList, 'Poll'>;

export default function PollScreen({ navigation }: PollScreenProps) {
  const [darkMode, setDarkMode] = useState(false);
  const [height, setHeight] = useState<number>(0);

  return (
    <SafeAreaView style={darkMode ? styles.containerDark : styles.containerNoPadding}>
      <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
        <View style={[styles.articleContent, styles.switchRow]}>
          <Text style={darkMode ? styles.darkText : styles.lightText}>Dark mode</Text>
          <Switch value={darkMode} onValueChange={setDarkMode} />
        </View>
        <PollView
          containerId={viafouraConfig.pollContainerId}
          theme={darkMode ? 'dark' : 'light'}
          colors={{ ...viafouraConfig.colors }}
          fonts={{ ...viafouraConfig.fonts }}
          style={[styles.articleContent, { height }]}
          onHeightChanged={(event) => {
            const next = event.nativeEvent?.newHeight;
            if (typeof next === 'number' && next >= 0) setHeight(next);
          }}
          onAuthNeeded={() => {
            navigation.navigate('Login', { reason: 'Sign in to vote.' });
          }}
          onAction={(event) => {
            console.log('Poll action', event.nativeEvent);
          }}
        />
      </ScrollView>
    </SafeAreaView>
  );
}

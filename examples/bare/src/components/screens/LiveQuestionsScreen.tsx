import React, { useState } from 'react';
import { Platform, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';

import { LiveQuestionsView } from '@viafoura/sdk-react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Screens } from '../../navigation/screens';
import { viafouraFonts } from '../../fonts';
import { viafouraColors } from '../../viafoura';

const styles = StyleSheet.create({
  light: { flex: 1, backgroundColor: '#FFFFFF' },
  dark: { flex: 1, backgroundColor: '#121212' },
  switchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
  },
  lightText: { color: '#1B2430' },
  darkText: { color: '#F2F4F7' },
});

const LiveQuestionsScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const [darkMode, setDarkMode] = useState(false);
  const [height, setHeight] = useState(600);

  return (
    <ScrollView style={darkMode ? styles.dark : styles.light}>
      <View style={styles.switchRow}>
        <Text style={darkMode ? styles.darkText : styles.lightText}>Dark mode</Text>
        <Switch value={darkMode} onValueChange={setDarkMode} />
      </View>
      <LiveQuestionsView
        style={{ height }}
        containerId={route.params.containerId}
        articleTitle={route.params.articleTitle}
        articleSubtitle={route.params.articleDesc}
        articleUrl={route.params.articleUrl}
        articleThumbnailUrl={route.params.articleThumbnailUrl}
        title={route.params.title}
        sectionUUID={route.params.sectionUUID}
        theme={darkMode ? 'dark' : 'light'}
        colors={viafouraColors}
        fonts={viafouraFonts}
        onHeightChanged={({ nativeEvent }) => setHeight(nativeEvent.newHeight)}
        onOpenProfile={({ nativeEvent }) => {
          if (Platform.OS !== 'android') return;
          navigation.navigate(Screens.Profile, {
            userUUID: nativeEvent.userUUID,
            presentationType: nativeEvent.presentationType ?? 'profile',
          });
        }}
        onAuthNeeded={() => navigation.navigate(Screens.Login)}
        onAction={({ nativeEvent }) => console.log('LiveQuestions action', nativeEvent)}
      />
    </ScrollView>
  );
};

export default LiveQuestionsScreen;

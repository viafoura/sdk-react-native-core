import React, { useState } from 'react';
import { ScrollView, StyleSheet, Switch, Text, View } from 'react-native';

import { PollView } from '@viafoura/sdk-react-native';
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
  poll: { marginHorizontal: 16 },
  lightText: { color: '#1B2430' },
  darkText: { color: '#F2F4F7' },
});

const PollScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const [darkMode, setDarkMode] = useState(false);
  const [height, setHeight] = useState(0);

  return (
    <ScrollView style={darkMode ? styles.dark : styles.light}>
      <View style={styles.switchRow}>
        <Text style={darkMode ? styles.darkText : styles.lightText}>Dark mode</Text>
        <Switch value={darkMode} onValueChange={setDarkMode} />
      </View>
      <PollView
        style={[styles.poll, { height }]}
        containerId={route.params.containerId}
        theme={darkMode ? 'dark' : 'light'}
        colors={viafouraColors}
        fonts={viafouraFonts}
        onHeightChanged={({ nativeEvent }) => setHeight(nativeEvent.newHeight)}
        onAuthNeeded={() => navigation.navigate(Screens.Login)}
        onAction={({ nativeEvent }) => console.log('Poll action', nativeEvent)}
      />
    </ScrollView>
  );
};

export default PollScreen;

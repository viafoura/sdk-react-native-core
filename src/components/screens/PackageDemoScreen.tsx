import React from 'react';
import { NativeModules, ScrollView, StyleSheet, Text, UIManager, View } from 'react-native';
import Viafoura, { PreviewCommentsView } from '@viafoura/sdk-react-native';

const CONTAINER_ID = '101113541';

const styles = StyleSheet.create({
  root: { flex: 1 },
  panel: { padding: 12, backgroundColor: '#f2f2f2' },
  line: { fontSize: 13, marginBottom: 2 },
  ok: { color: '#0a7d28' },
  bad: { color: '#b00020' },
  comments: { height: 420 },
});

const PackageDemoScreen = () => {
  const [initState] = React.useState('skipped (AppDelegate already initialized the native SDK)');

  const moduleFound = NativeModules.Viafoura != null;
  const customUIFound = NativeModules.ViafouraCustomUI != null;
  const previewFound = UIManager.getViewManagerConfig('PreviewComments') != null;
  const starterFound = UIManager.getViewManagerConfig('ConversationStarter') != null;
  const authFns = moduleFound
    ? ['login', 'logout', 'signup', 'initialize'].filter(
        (k) => typeof (Viafoura as any)[k] === 'function'
      ).length
    : 0;

  const row = (label: string, good: boolean, detail?: string) => (
    <Text style={[styles.line, good ? styles.ok : styles.bad]}>
      {good ? 'PASS' : 'FAIL'} {label}
      {detail ? ' — ' + detail : ''}
    </Text>
  );

  return (
    <ScrollView style={styles.root}>
      <View style={styles.panel}>
        <Text style={styles.line}>@viafoura/sdk-react-native runtime check</Text>
        {row('NativeModules.Viafoura', moduleFound)}
        {row('NativeModules.ViafouraCustomUI', customUIFound)}
        {row('ViewManager PreviewComments', previewFound)}
        {row('ViewManager ConversationStarter', starterFound)}
        {row('auth functions exposed', authFns === 4, authFns + '/4')}
        <Text style={styles.line}>initialize(): {initState}</Text>
      </View>
      <PreviewCommentsView
        style={styles.comments}
        containerId={CONTAINER_ID}
        articleUrl="https://viafoura-mobile-demo.vercel.app/posts/here-are-what-media-companies-are-doing-with-covid-19-overload"
        articleTitle="Moving Staff to Cover the Coronavirus"
        articleThumbnailUrl="https://www.datocms-assets.com/55856/1636753460-information-overload.jpg"
      />
    </ScrollView>
  );
};

export default PackageDemoScreen;

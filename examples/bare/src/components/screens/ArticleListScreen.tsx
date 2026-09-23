import React from 'react';
import { ScrollView, Button } from 'react-native';

import { useNavigation, useRoute } from '@react-navigation/native';
import { Screens } from '../../navigation/screens';

const ArticleListScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  return (
    <ScrollView>
      <Button
        title="Article 1"
        onPress={() =>
          navigation.navigate(Screens.Article, route.params.articles[0])
        }
      />
      <Button
        title="Article 2"
        onPress={() =>
          navigation.navigate(Screens.Article, route.params.articles[1])
        }
      />
      <Button
        title="Live Q&A"
        onPress={() =>
          navigation.navigate(Screens.LiveQuestions, {
            ...route.params.articles[1],
            title: 'Live Q&A',
          })
        }
      />
    </ScrollView>
  );
};

export default ArticleListScreen;

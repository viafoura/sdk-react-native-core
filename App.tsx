import React from 'react';

import ArticleListScreen from './src/components/screens/ArticleListScreen';
import ArticleScreen from './src/components/screens/ArticleScreen';
import LiveQuestionsScreen from './src/components/screens/LiveQuestionsScreen';
import ProfileScreen from './src/components/screens/ProfileScreen';
import NewCommentScreen from './src/components/screens/NewCommentScreen';
import LoginScreen from './src/components/screens/LoginScreen';
import SignUpScreen from './src/components/screens/SignUpScreen';
import ForgotPasswordScreen from './src/components/screens/ForgotPasswordScreen';

import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Screens } from './src/navigation/screens';
import Viafoura from '@viafoura/sdk-react-native';

const Stack = createNativeStackNavigator();

const SITE_UUID = '00000000-0000-4000-8000-c8cddfd7b365';
const SITE_DOMAIN = 'viafoura-mobile-demo.vercel.app';

const App = () => {
  React.useEffect(() => {
    Viafoura.initialize(SITE_UUID, SITE_DOMAIN, true).catch((error) => {
      console.log(error);
    });
  }, []);

  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name={Screens.ArticleList}
          initialParams={{
            articles: [
              {
                containerId: '101113541',
                authorId: '7548800024996',
                articleTitle: 'Moving Staff to Cover the Coronavirus',
                articleDesc:
                  'Here Are What Media Companies Are Doing to Deal With COVID-19 Information Overload',
                articleUrl:
                  'https://viafoura-mobile-demo.vercel.app/posts/here-are-what-media-companies-are-doing-with-covid-19-overload',
                articleThumbnailUrl:
                  'https://www.datocms-assets.com/55856/1636753460-information-overload.jpg?crop=focalpoint&fit=crop&fm=webp&fp-x=0.86&fp-y=0.47&h=428&w=856',
              },
              {
                containerId: '1254',
                authorId: '7548800024996',
                articleTitle: 'Moving Staff to Cover the Coronavirus',
                articleDesc:
                  'Here Are What Media Companies Are Doing to Deal With COVID-19 Information Overload',
                articleUrl:
                  'https://viafoura-mobile-demo.vercel.app/posts/here-are-what-media-companies-are-doing-with-covid-19-overload',
                articleThumbnailUrl:
                  'https://www.datocms-assets.com/55856/1636753460-information-overload.jpg?crop=focalpoint&fit=crop&fm=webp&fp-x=0.86&fp-y=0.47&h=428&w=856',
              },
            ],
          }}
          component={ArticleListScreen}
        />
        <Stack.Screen name={Screens.Article} component={ArticleScreen} />
        <Stack.Screen
          name={Screens.LiveQuestions}
          component={LiveQuestionsScreen}
        />
        <Stack.Screen name={Screens.NewComment} component={NewCommentScreen} />
        <Stack.Screen name={Screens.Profile} component={ProfileScreen} />
        <Stack.Screen name={Screens.Login} component={LoginScreen} />
        <Stack.Screen name={Screens.Signup} component={SignUpScreen} />
        <Stack.Screen
          name={Screens.ForgotPassword}
          component={ForgotPasswordScreen}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App;

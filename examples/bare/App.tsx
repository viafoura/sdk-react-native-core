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
import { SITE_DOMAIN, SITE_UUID, articles } from './src/viafoura';
import { applyCustomUI } from './src/customUI';

const Stack = createNativeStackNavigator();

applyCustomUI();

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
          initialParams={{ articles }}
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

import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import Viafoura from '@viafoura/sdk-react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import type { RootStackParamList } from './navigation/types';
import { viafouraConfig } from './viafouraConfig';
import { applyCustomUI } from './customUI';
import CommentsScreen from './screens/CommentsScreen';
import LiveQuestionsScreen from './screens/LiveQuestionsScreen';
import LoginScreen from './screens/LoginScreen';
import SignUpScreen from './screens/SignUpScreen';
import ForgotPasswordScreen from './screens/ForgotPasswordScreen';
import NewCommentScreen from './screens/NewCommentScreen';
import ProfileScreen from './screens/ProfileScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();

applyCustomUI();

export default function App() {
  const [initError, setInitError] = useState<string | null>(null);
  useEffect(() => {
    let isMounted = true;
    Viafoura.initialize(viafouraConfig.siteUUID, viafouraConfig.siteDomain, true)
      .catch((err) => {
        if (!isMounted) return;
        const message = err instanceof Error ? err.message : String(err);
        setInitError(message);
      });
    return () => {
      isMounted = false;
    };
  }, []);

  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Comments" options={{ title: 'Viafoura' }}>
          {(props) => <CommentsScreen {...props} initError={initError} />}
        </Stack.Screen>
        <Stack.Screen
          name="LiveQuestions"
          component={LiveQuestionsScreen}
          options={{ title: viafouraConfig.liveQuestionsTitle }}
        />
        <Stack.Screen name="NewComment" options={{ title: 'New Comment' }}>
          {(props) => <NewCommentScreen {...props} />}
        </Stack.Screen>
        <Stack.Screen name="Profile" options={{ title: 'Profile' }}>
          {(props) => <ProfileScreen {...props} />}
        </Stack.Screen>
        <Stack.Screen name="Login" options={{ title: 'Login' }}>
          {(props) => <LoginScreen {...props} />}
        </Stack.Screen>
        <Stack.Screen name="SignUp" component={SignUpScreen} options={{ title: 'Sign up' }} />
        <Stack.Screen
          name="ForgotPassword"
          component={ForgotPasswordScreen}
          options={{ title: 'Reset password' }}
        />
      </Stack.Navigator>
      <StatusBar style="auto" />
    </NavigationContainer>
  );
}

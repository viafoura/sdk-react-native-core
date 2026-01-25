import { useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  SafeAreaView,
  Text,
  TextInput,
  View,
} from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import Viafoura from '@viafoura/sdk-react-native';

import type { RootStackParamList } from '../navigation/types';
import { styles } from '../styles';

type LoginScreenProps = NativeStackScreenProps<RootStackParamList, 'Login'>;

export default function LoginScreen({ navigation, route }: LoginScreenProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        style={styles.loginContainer}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <Text style={styles.loginTitle}>Sign in to continue</Text>
        {route.params?.reason ? (
          <Text style={styles.loginSubtitle}>{route.params.reason}</Text>
        ) : null}
        <View style={styles.loginField}>
          <Text style={styles.loginLabel}>Email</Text>
          <TextInput
            style={styles.loginInput}
            autoCapitalize="none"
            keyboardType="email-address"
            placeholder="you@example.com"
            value={email}
            onChangeText={setEmail}
          />
        </View>
        <View style={styles.loginField}>
          <Text style={styles.loginLabel}>Password</Text>
          <TextInput
            style={styles.loginInput}
            placeholder="••••••••"
            secureTextEntry
            value={password}
            onChangeText={setPassword}
          />
        </View>
        {error ? <Text style={styles.loginError}>{error}</Text> : null}
        <Pressable
          style={[styles.loginPrimaryButton, submitting && styles.loginPrimaryButtonDisabled]}
          disabled={submitting}
          onPress={async () => {
            if (!email || !password) {
              setError('Enter your email and password.');
              return;
            }
            setSubmitting(true);
            setError(null);
            try {
              await Viafoura.login(email, password);
              navigation.goBack();
            } catch (err) {
              const message = err instanceof Error ? err.message : String(err);
              setError(message);
            } finally {
              setSubmitting(false);
            }
          }}
        >
          <Text style={styles.loginPrimaryButtonText}>
            {submitting ? 'Signing In…' : 'Sign In'}
          </Text>
        </Pressable>
        <Pressable
          style={styles.loginSecondaryButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.loginSecondaryButtonText}>Cancel</Text>
        </Pressable>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

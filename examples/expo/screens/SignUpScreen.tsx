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

type SignUpScreenProps = NativeStackScreenProps<RootStackParamList, 'SignUp'>;

export default function SignUpScreen({ navigation }: SignUpScreenProps) {
  const [name, setName] = useState('');
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
        <Text style={styles.loginTitle}>Create an account</Text>
        <View style={styles.loginField}>
          <Text style={styles.loginLabel}>Name</Text>
          <TextInput
            style={styles.loginInput}
            placeholder="Your name"
            value={name}
            onChangeText={setName}
          />
        </View>
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
            if (!name || !email || !password) {
              setError('Enter your name, email and password.');
              return;
            }
            setSubmitting(true);
            setError(null);
            try {
              await Viafoura.signup(name, email, password);
              navigation.popToTop();
            } catch (err) {
              setError(err instanceof Error ? err.message : String(err));
            } finally {
              setSubmitting(false);
            }
          }}
        >
          <Text style={styles.loginPrimaryButtonText}>
            {submitting ? 'Creating…' : 'Sign Up'}
          </Text>
        </Pressable>
        <Pressable style={styles.loginSecondaryButton} onPress={() => navigation.goBack()}>
          <Text style={styles.loginSecondaryButtonText}>Back to sign in</Text>
        </Pressable>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

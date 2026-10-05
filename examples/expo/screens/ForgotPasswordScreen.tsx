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

type ForgotPasswordScreenProps = NativeStackScreenProps<RootStackParamList, 'ForgotPassword'>;

export default function ForgotPasswordScreen({ navigation }: ForgotPasswordScreenProps) {
  const [email, setEmail] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        style={styles.loginContainer}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <Text style={styles.loginTitle}>Reset your password</Text>
        <Text style={styles.loginSubtitle}>
          We will email you a link to choose a new password.
        </Text>
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
        {error ? <Text style={styles.loginError}>{error}</Text> : null}
        {sent ? <Text style={styles.loginSubtitle}>Check your inbox.</Text> : null}
        <Pressable
          style={[styles.loginPrimaryButton, submitting && styles.loginPrimaryButtonDisabled]}
          disabled={submitting}
          onPress={async () => {
            if (!email) {
              setError('Enter your email.');
              return;
            }
            setSubmitting(true);
            setError(null);
            try {
              await Viafoura.resetPassword(email);
              setSent(true);
            } catch (err) {
              setError(err instanceof Error ? err.message : String(err));
            } finally {
              setSubmitting(false);
            }
          }}
        >
          <Text style={styles.loginPrimaryButtonText}>
            {submitting ? 'Sending…' : 'Send reset email'}
          </Text>
        </Pressable>
        <Pressable style={styles.loginSecondaryButton} onPress={() => navigation.goBack()}>
          <Text style={styles.loginSecondaryButtonText}>Back to sign in</Text>
        </Pressable>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

import { StyleSheet } from 'react-native';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  containerNoPadding: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    marginBottom: 8,
  },
  subtitle: {
    color: '#5a6472',
    fontSize: 16,
    lineHeight: 22,
    marginBottom: 12,
  },
  error: {
    color: '#b00020',
    marginBottom: 8,
  },
  platform: {
    color: '#7b8594',
    marginBottom: 12,
  },
  previewContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    overflow: 'hidden',
    borderColor: '#e1e5ee',
    borderWidth: 1,
    flex: 1,
  },
  scroll: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
  articleContent: {
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 12,
  },
  loginContainer: {
    flex: 1,
    gap: 12,
    paddingTop: 24,
    paddingHorizontal: 16,
  },
  loginTitle: {
    fontSize: 22,
    fontWeight: '600',
  },
  loginSubtitle: {
    color: '#5a6472',
    fontSize: 14,
  },
  loginField: {
    gap: 6,
  },
  loginLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#1b2430',
  },
  loginInput: {
    borderWidth: 1,
    borderColor: '#d6dbe5',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
    backgroundColor: '#ffffff',
  },
  loginError: {
    color: '#b00020',
    fontSize: 13,
  },
  loginPrimaryButton: {
    backgroundColor: '#0a6ee8',
    borderRadius: 10,
    paddingVertical: 12,
    alignItems: 'center',
  },
  loginPrimaryButtonDisabled: {
    opacity: 0.6,
  },
  loginPrimaryButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  loginSecondaryButton: {
    alignItems: 'center',
    paddingVertical: 10,
  },
  loginSecondaryButtonText: {
    color: '#0a6ee8',
    fontWeight: '600',
  },
  previewContainerFlat: {
    borderRadius: 0,
    borderWidth: 0,
  },
  preview: {
    flex: 1,
  },
  actionsRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
  },
  actionButton: {
    backgroundColor: '#0a6ee8',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  actionButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
});

export type RootStackParamList = {
  Comments: undefined;
  LiveQuestions: undefined;
  NewComment: { actionType: 'create' | 'edit' | 'reply'; content?: string };
  Profile: { userUUID: string; presentationType?: 'profile' | 'feed' };
  Login: { reason?: string } | undefined;
  SignUp: undefined;
  ForgotPassword: undefined;
};

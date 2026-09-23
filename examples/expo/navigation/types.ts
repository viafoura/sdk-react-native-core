export type RootStackParamList = {
  Comments: undefined;
  NewComment: { actionType: 'create' | 'edit' | 'reply'; content?: string };
  Profile: { userUUID: string; presentationType?: 'profile' | 'feed' };
  Login: { reason?: string } | undefined;
};

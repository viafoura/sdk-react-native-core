import type { StyleProp, ViewStyle } from 'react-native';

export type ViafouraModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
};

export type ChangeEventPayload = {
  value: string;
};


export type PreviewCommentsEvents =
  | 'onHeightChanged'
  | 'onAuthNeeded'
  | 'onOpenProfile'
  | 'onNewComment'
  | 'onArticlePressed';

export type PreviewCommentsHeightChangedPayload = {
  newHeight: number;
  containerId: string;
};

export type PreviewCommentsAuthNeededPayload = {
  requireLogin?: boolean;
};

export type PreviewCommentsOpenProfilePayload = {
  userUUID: string;
  presentationType?: string;
};

export type PreviewCommentsNewCommentPayload = {
  content?: string;
  actionType?: string;
};

export type PreviewCommentsArticlePressedPayload = {
  articleUrl: string;
  containerId: string;
};

export type PreviewCommentsViewProps = {
  containerId: string;
  authorId?: string;
  articleUrl: string;
  articleTitle: string;
  articleSubtitle?: string;
  articleThumbnailUrl: string;
  syndicationKey?: string;
  darkMode?: boolean;
  onHeightChanged?: (event: { nativeEvent: PreviewCommentsHeightChangedPayload }) => void;
  onAuthNeeded?: (event: { nativeEvent: PreviewCommentsAuthNeededPayload }) => void;
  onOpenProfile?: (event: { nativeEvent: PreviewCommentsOpenProfilePayload }) => void;
  onNewComment?: (event: { nativeEvent: PreviewCommentsNewCommentPayload }) => void;
  onArticlePressed?: (event: { nativeEvent: PreviewCommentsArticlePressedPayload }) => void;
  style?: StyleProp<ViewStyle>;
};

export type ProfileAuthNeededPayload = {
  requireLogin?: boolean;
};

export type ProfileViewProps = {
  userUUID: string;
  presentationType?: 'profile' | 'feed';
  darkMode?: boolean;
  onAuthNeeded?: (event: { nativeEvent: ProfileAuthNeededPayload }) => void;
  onCloseProfile?: (event: { nativeEvent: Record<string, never> }) => void;
  style?: StyleProp<ViewStyle>;
};

export type NewCommentHeightChangedPayload = PreviewCommentsHeightChangedPayload;
export type NewCommentAuthNeededPayload = PreviewCommentsAuthNeededPayload;

export type NewCommentViewProps = {
  newCommentActionType: 'create' | 'edit' | 'reply';
  content?: string; // UUID as string
  containerId: string;
  syndicationKey?: string;
  articleTitle: string;
  articleSubtitle?: string;
  articleUrl: string;
  articleThumbnailUrl: string;
  darkMode?: boolean;
  onHeightChanged?: (event: { nativeEvent: NewCommentHeightChangedPayload }) => void;
  onAuthNeeded?: (event: { nativeEvent: NewCommentAuthNeededPayload }) => void;
  onCloseNewComment?: (event: { nativeEvent: Record<string, never> }) => void;
  style?: StyleProp<ViewStyle>;
};

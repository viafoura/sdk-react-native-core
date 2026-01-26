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
  | 'onArticlePressed'
  | 'onAction';

export type ViafouraColors = {
  colorPrimary?: string;
  colorPrimaryLight?: string;
  colorAvatars?: string[];
};

export type ActionCallbackType =
  | 'writeNewCommentPressed'
  | 'trendingArticlePressed'
  | 'openProfilePressed'
  | 'seeMoreCommentsPressed'
  | 'notificationPressed'
  | 'commentPosted'
  | 'replyPosted'
  | 'authPressed'
  | 'closeNewCommentPressed'
  | 'closeProfilePressed';

export type ActionCallbackPayload =
  | {
      type: 'writeNewCommentPressed';
      actionType?: 'create' | 'edit' | 'reply';
      content?: string;
    }
  | {
      type: 'trendingArticlePressed';
      containerId?: string;
      articleUrl?: string;
    }
  | {
      type: 'openProfilePressed';
      userUUID?: string;
      presentationType?: 'profile' | 'feed';
    }
  | {
      type: 'seeMoreCommentsPressed';
    }
  | {
      type: 'notificationPressed';
      presentationType?: 'profile' | 'content';
      userUUID?: string;
      containerUUID?: string;
      contentUUID?: string;
      containerId?: string;
      articleUrl?: string;
    }
  | {
      type: 'commentPosted';
      content?: string;
    }
  | {
      type: 'replyPosted';
      content?: string;
    }
  | {
      type: 'authPressed';
      requireLogin?: boolean;
    }
  | {
      type: 'closeNewCommentPressed';
    }
  | {
      type: 'closeProfilePressed';
    };

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
  theme?: 'light' | 'dark';
  colors?: ViafouraColors;
  onHeightChanged?: (event: { nativeEvent: PreviewCommentsHeightChangedPayload }) => void;
  onAuthNeeded?: (event: { nativeEvent: PreviewCommentsAuthNeededPayload }) => void;
  onOpenProfile?: (event: { nativeEvent: PreviewCommentsOpenProfilePayload }) => void;
  onNewComment?: (event: { nativeEvent: PreviewCommentsNewCommentPayload }) => void;
  onArticlePressed?: (event: { nativeEvent: PreviewCommentsArticlePressedPayload }) => void;
  onAction?: (event: { nativeEvent: ActionCallbackPayload }) => void;
  style?: StyleProp<ViewStyle>;
};

export type ProfileAuthNeededPayload = {
  requireLogin?: boolean;
};

export type ProfileViewProps = {
  userUUID: string;
  presentationType?: 'profile' | 'feed';
  darkMode?: boolean;
  theme?: 'light' | 'dark';
  colors?: ViafouraColors;
  onAuthNeeded?: (event: { nativeEvent: ProfileAuthNeededPayload }) => void;
  onCloseProfile?: (event: { nativeEvent: Record<string, never> }) => void;
  onAction?: (event: { nativeEvent: ActionCallbackPayload }) => void;
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
  theme?: 'light' | 'dark';
  colors?: ViafouraColors;
  onHeightChanged?: (event: { nativeEvent: NewCommentHeightChangedPayload }) => void;
  onAuthNeeded?: (event: { nativeEvent: NewCommentAuthNeededPayload }) => void;
  onCloseNewComment?: (event: { nativeEvent: Record<string, never> }) => void;
  onAction?: (event: { nativeEvent: ActionCallbackPayload }) => void;
  style?: StyleProp<ViewStyle>;
};

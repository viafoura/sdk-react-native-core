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

export const CustomUIVisibility = {
  Visible: 'visible',
  Hidden: 'hidden',
} as const;
export type VFCustomUIVisibility = (typeof CustomUIVisibility)[keyof typeof CustomUIVisibility];

export const CustomUITheme = {
  Light: 'light',
  Dark: 'dark',
} as const;
export type VFCustomUITheme = (typeof CustomUITheme)[keyof typeof CustomUITheme];

export type VFCustomUIStyle = {
  visibility?: VFCustomUIVisibility;
  backgroundColor?: `#${string}`;
};

export const IOSCustomUIViewType = {
  postButton: 'postButton',
  postTextView: 'postTextView',
  postCloseImage: 'postCloseImage',
  postUserImage: 'postUserImage',
  postUserAvatar: 'postUserAvatar',
  postMetadataTitle: 'postMetadataTitle',
  postMetadataImage: 'postMetadataImage',
  postMetadataDescription: 'postMetadataDescription',
  postHeaderDescription: 'postHeaderDescription',
  postPlaceholderLabel: 'postPlaceholderLabel',
  postImageSkeletonView: 'postImageSkeletonView',
  postTitleSkeletonView: 'postTitleSkeletonView',
  postDescriptionSkeletonView: 'postDescriptionSkeletonView',
  postBackgroundView: 'postBackgroundView',
  profileNameLabel: 'profileNameLabel',
  profileLogoutLabel: 'profileLogoutLabel',
  profileCloseImage: 'profileCloseImage',
  profileLikesLabel: 'profileLikesLabel',
  profileFollowersLabel: 'profileFollowersLabel',
  profileSegmentedControl: 'profileSegmentedControl',
  profileCommunityTabView: 'profileCommunityTabView',
  profileFollowView: 'profileFollowView',
  profileBackgroundView: 'profileBackgroundView',
  commentCellExpandRepliesLoading: 'commentCellExpandRepliesLoading',
  commentCellExpandRepliesImage: 'commentCellExpandRepliesImage',
  commentCellExpandRepliesLabel: 'commentCellExpandRepliesLabel',
  commentCellDateLabel: 'commentCellDateLabel',
  commentCellNameLabel: 'commentCellNameLabel',
  commentCellContentLabel: 'commentCellContentLabel',
  commentCellOptionsButton: 'commentCellOptionsButton',
  commentCellLikeImage: 'commentCellLikeImage',
  commentCellLikeLabel: 'commentCellLikeLabel',
  commentCellDislikeImage: 'commentCellDislikeImage',
  commentCellTrustedView: 'commentCellTrustedView',
  commentCellModeratorView: 'commentCellModeratorView',
  commentCellAuthorView: 'commentCellAuthorView',
  commentCellFollowView: 'commentCellFollowView',
  commentCellDislikeLabel: 'commentCellDislikeLabel',
  commentCellReplyLabel: 'commentCellReplyLabel',
  commentCellReplyImage: 'commentCellReplyImage',
  commentCellUserImage: 'commentCellUserImage',
  commentCellUserAvatar: 'commentCellUserAvatar',
  commentCellUserIndicator: 'commentCellUserIndicator',
  commentCellAwaitingModerationView: 'commentCellAwaitingModerationView',
  commentCellCustomBadge: 'commentCellCustomBadge',
  commentCellPinnedView: 'commentCellPinnedView',
  commentCellEditorPickView: 'commentCellEditorPickView',
  commentCellSeparator: 'commentCellSeparator',
  userCommentDescLabel: 'userCommentDescLabel',
  userCommentOriginalImage: 'userCommentOriginalImage',
  userCommentOriginalTitle: 'userCommentOriginalTitle',
  userCommentContentLabel: 'userCommentContentLabel',
  userCommentSeparator: 'userCommentSeparator',
  userCommentDateLabel: 'userCommentDateLabel',
  userCellImage: 'userCellImage',
  userCellAvatarView: 'userCellAvatarView',
  userCellNameLabel: 'userCellNameLabel',
  userCellActionDateLabel: 'userCellActionDateLabel',
  userCellBadgeLabel: 'userCellBadgeLabel',
  userCellBadgeView: 'userCellBadgeView',
  userCellSeparator: 'userCellSeparator',
  userCellFollowView: 'userCellFollowView',
  conversationStarterBackgroundView: 'conversationStarterBackgroundView',
  conversationStarterHeaderLabel: 'conversationStarterHeaderLabel',
  conversationStarterTitleLabel: 'conversationStarterTitleLabel',
  conversationStarterDescriptionLabel: 'conversationStarterDescriptionLabel',
  conversationStarterFeaturedCommentLabel: 'conversationStarterFeaturedCommentLabel',
  conversationStarterActionButton: 'conversationStarterActionButton',
  previewEmptyCommentsView: 'previewEmptyCommentsView',
  previewSeeMoreCommentsButton: 'previewSeeMoreCommentsButton',
  previewTitleLabel: 'previewTitleLabel',
  previewPrivacyLabel: 'previewPrivacyLabel',
  previewUserPromptLabel: 'previewUserPromptLabel',
  previewLoginLabel: 'previewLoginLabel',
  previewAuthOrLabel: 'previewAuthOrLabel',
  previewSignupLabel: 'previewSignupLabel',
  previewUserImage: 'previewUserImage',
  previewUserAvatar: 'previewUserAvatar',
  previewUserSomeoneWritingLabel: 'previewUserSomeoneWritingLabel',
  previewNewCommentsNotificationView: 'previewNewCommentsNotificationView',
  previewCommentPrompt: 'previewCommentPrompt',
  previewNotificationBellView: 'previewNotificationBellView',
  previewHeaderView: 'previewHeaderView',
  previewSortImage: 'previewSortImage',
  previewSortLabel: 'previewSortLabel',
  previewAllComments: 'previewAllComments',
  previewPoweredByView: 'previewPoweredByView',
  previewSkeletonView: 'previewSkeletonView',
  previewFollowView: 'previewFollowView',
  previewBackgroundView: 'previewBackgroundView',
  reportReasonOptionLabel: 'reportReasonOptionLabel',
  reportTitleLabel: 'reportTitleLabel',
  reportPickReasonLabel: 'reportPickReasonLabel',
  reportStartCloseLabel: 'reportStartCloseLabel',
  reportStartDescriptionLabel: 'reportStartDescriptionLabel',
  reportStartButton: 'reportStartButton',
  reportChosenTitleLabel: 'reportChosenTitleLabel',
  reportChosenDescriptionLabel: 'reportChosenDescriptionLabel',
  reportChosenCloseLabel: 'reportChosenCloseLabel',
  reportChosenButton: 'reportChosenButton',
  reportThanksLabel: 'reportThanksLabel',
  reportThanksButton: 'reportThanksButton',
  trendingVerticalBackgroundView: 'trendingVerticalBackgroundView',
  trendingVerticalTitleLabel: 'trendingVerticalTitleLabel',
  trendingVerticalFullImage: 'trendingVerticalFullImage',
  trendingVerticalFullImageIcon: 'trendingVerticalFullImageIcon',
  trendingVerticalFullTitle: 'trendingVerticalFullTitle',
  trendingVerticalFullCount: 'trendingVerticalFullCount',
  trendingVerticalViewMoreButton: 'trendingVerticalViewMoreButton',
  trendingVerticalCondensedTitle: 'trendingVerticalCondensedTitle',
  trendingVerticalCondensedCount: 'trendingVerticalCondensedCount',
  trendingCarouselTitle: 'trendingCarouselTitle',
  trendingCarouselImage: 'trendingCarouselImage',
  trendingCarouselCount: 'trendingCarouselCount',
  trendingCarouselBackgroundView: 'trendingCarouselBackgroundView',
  bottomPickerView: 'bottomPickerView',
  bottomPickerTitle: 'bottomPickerTitle',
  bottomPickerTitleLabel: 'bottomPickerTitleLabel',
  bottomPickerLabel: 'bottomPickerLabel',
  bottomPickerSeparator: 'bottomPickerSeparator',
  chatCellContentLabel: 'chatCellContentLabel',
  chatCellDateLabel: 'chatCellDateLabel',
  chatCellUserNameLabel: 'chatCellUserNameLabel',
  chatPostView: 'chatPostView',
  chatPostImage: 'chatPostImage',
  chatPostLoading: 'chatPostLoading',
  chatTextView: 'chatTextView',
  chatBackgroundView: 'chatBackgroundView',
  chatLoading: 'chatLoading',
  chatLoadingMore: 'chatLoadingMore',
  chatEmptyView: 'chatEmptyView',
  notificationContentImage: 'notificationContentImage',
  notificationRemoveImage: 'notificationRemoveImage',
  notificationTrendingCountImage: 'notificationTrendingCountImage',
  notificationTrendingImage: 'notificationTrendingImage',
  notificationTrendingIcon: 'notificationTrendingIcon',
  notificationGroupTitleLabel: 'notificationGroupTitleLabel',
  notificationBellText: 'notificationBellText',
  notificationBellIcon: 'notificationBellIcon',
} as const;

export type IOSCustomViewType = (typeof IOSCustomUIViewType)[keyof typeof IOSCustomUIViewType];

export const AndroidCustomUIViewType = {
  commentCellDislikeImage: 'commentCellDislikeImage',
  commentCellDislikeText: 'commentCellDislikeText',
  commentCellLikeImage: 'commentCellLikeImage',
  commentCellLikeText: 'commentCellLikeText',
  commentCellUserImage: 'commentCellUserImage',
  commentCellUserAvatar: 'commentCellUserAvatar',
  commentCellDateText: 'commentCellDateText',
  commentCellOptionsImage: 'commentCellOptionsImage',
  commentCellUserText: 'commentCellUserText',
  commentCellReplyImage: 'commentCellReplyImage',
  commentCellFollowView: 'commentCellFollowView',
  commentCellCommentText: 'commentCellCommentText',
  commentCellReplyText: 'commentCellReplyText',
  commentCellCustomBadgeView: 'commentCellCustomBadgeView',
  commentCellPinnedView: 'commentCellPinnedView',
  commentCellEditorPickView: 'commentCellEditorPickView',
  commentCellTrustedView: 'commentCellTrustedView',
  commentCellAuthorView: 'commentCellAuthorView',
  commentCellModeratorView: 'commentCellModeratorView',
  commentCellUserIndicatorHolder: 'commentCellUserIndicatorHolder',
  commentCellUserIndicatorImage: 'commentCellUserIndicatorImage',
  commentCellAwaitingModerationView: 'commentCellAwaitingModerationView',
  commentCellExpandRepliesLabel: 'commentCellExpandRepliesLabel',
  commentCellExpandRepliesImage: 'commentCellExpandRepliesImage',
  commentCellExpandRepliesLoading: 'commentCellExpandRepliesLoading',
  userCommentDescLabel: 'userCommentDescLabel',
  userCommentOriginalImage: 'userCommentOriginalImage',
  userCommentOriginalTitle: 'userCommentOriginalTitle',
  userCommentContentLabel: 'userCommentContentLabel',
  userCommentSeparator: 'userCommentSeparator',
  userCommentDateLabel: 'userCommentDateLabel',
  userCellImage: 'userCellImage',
  userCellAvatarView: 'userCellAvatarView',
  userCellNameLabel: 'userCellNameLabel',
  userCellActionDateLabel: 'userCellActionDateLabel',
  userCellBadgeLabel: 'userCellBadgeLabel',
  userCellBadgeView: 'userCellBadgeView',
  userCellSeparator: 'userCellSeparator',
  userCellFollowView: 'userCellFollowView',
  postButton: 'postButton',
  postEditText: 'postEditText',
  postBackgroundView: 'postBackgroundView',
  postHeaderDescription: 'postHeaderDescription',
  postMetadataTitle: 'postMetadataTitle',
  postMetadataImage: 'postMetadataImage',
  postUserAvatar: 'postUserAvatar',
  postUserImage: 'postUserImage',
  postMetadataDescription: 'postMetadataDescription',
  postLoadingView: 'postLoadingView',
  bottomPickerView: 'bottomPickerView',
  bottomPickerTitleLabel: 'bottomPickerTitleLabel',
  bottomPickerLabel: 'bottomPickerLabel',
  profileNameText: 'profileNameText',
  profileCommunityTabText: 'profileCommunityTabText',
  profileCommunityTabView: 'profileCommunityTabView',
  profileMainTabText: 'profileMainTabText',
  profileFeedTabText: 'profileFeedTabText',
  profileLogoutText: 'profileLogoutText',
  profileLikesText: 'profileLikesText',
  profileFollowersText: 'profileFollowersText',
  profileBackgroundView: 'profileBackgroundView',
  profileFollowView: 'profileFollowView',
  conversationStarterBackgroundView: 'conversationStarterBackgroundView',
  conversationStarterHeaderLabel: 'conversationStarterHeaderLabel',
  conversationStarterTitleLabel: 'conversationStarterTitleLabel',
  conversationStarterDescriptionLabel: 'conversationStarterDescriptionLabel',
  conversationStarterFeaturedCommentLabel: 'conversationStarterFeaturedCommentLabel',
  conversationStarterActionButton: 'conversationStarterActionButton',
  previewEmptyCommentsView: 'previewEmptyCommentsView',
  previewTitleText: 'previewTitleText',
  previewCounterText: 'previewCounterText',
  previewSkeletonView: 'previewSkeletonView',
  previewNewCommentView: 'previewNewCommentView',
  previewPoweredBy: 'previewPoweredBy',
  previewAllComments: 'previewAllComments',
  previewSortImage: 'previewSortImage',
  previewUserImage: 'previewUserImage',
  previewUserAvatar: 'previewUserAvatar',
  previewUserPromptText: 'previewUserPromptText',
  previewLoginText: 'previewLoginText',
  previewAuthOrText: 'previewAuthOrText',
  previewSignupText: 'previewSignupText',
  previewSortText: 'previewSortText',
  previewCommentPrompt: 'previewCommentPrompt',
  previewPrivacyText: 'previewPrivacyText',
  previewBackgroundView: 'previewBackgroundView',
  previewFollowView: 'previewFollowView',
  previewHeaderView: 'previewHeaderView',
  previewNotificationBellView: 'previewNotificationBellView',
  previewNewCommentsView: 'previewNewCommentsView',
  previewNewCommentsViewText: 'previewNewCommentsViewText',
  previewUserSomeoneWritingLabel: 'previewUserSomeoneWritingLabel',
  previewNewCommentsNotificationView: 'previewNewCommentsNotificationView',
  previewSeeMoreCommentsButton: 'previewSeeMoreCommentsButton',
  trendingCarouselTitle: 'trendingCarouselTitle',
  trendingCarouselImage: 'trendingCarouselImage',
  trendingCarouselCount: 'trendingCarouselCount',
  trendingCarouselBackground: 'trendingCarouselBackground',
  trendingVerticalBackground: 'trendingVerticalBackground',
  trendingVerticalTitleLabel: 'trendingVerticalTitleLabel',
  trendingVerticalFullImage: 'trendingVerticalFullImage',
  trendingVerticalFullTitle: 'trendingVerticalFullTitle',
  trendingVerticalFullCount: 'trendingVerticalFullCount',
  trendingVerticalFullImageIcon: 'trendingVerticalFullImageIcon',
  trendingVerticalViewMoreButton: 'trendingVerticalViewMoreButton',
  chatPostButton: 'chatPostButton',
  chatPostImage: 'chatPostImage',
  chatPostLoading: 'chatPostLoading',
  chatEditText: 'chatEditText',
  chatLoading: 'chatLoading',
  chatLoadingMore: 'chatLoadingMore',
  chatEmptyView: 'chatEmptyView',
  chatCellContentLabel: 'chatCellContentLabel',
  chatCellDateLabel: 'chatCellDateLabel',
  chatCellUserNameLabel: 'chatCellUserNameLabel',
  notificationBellIcon: 'notificationBellIcon',
  notificationBellText: 'notificationBellText',
  notificationBellTextHolder: 'notificationBellTextHolder',
  notificationContentImage: 'notificationContentImage',
  notificationRemoveImage: 'notificationRemoveImage',
  notificationTrendingCountImage: 'notificationTrendingCountImage',
  notificationTrendingImage: 'notificationTrendingImage',
  notificationTrendingIcon: 'notificationTrendingIcon',
  notificationTodayGroupTitleLabel: 'notificationTodayGroupTitleLabel',
  notificationYesterdayGroupTitleLabel: 'notificationYesterdayGroupTitleLabel',
  notificationOlderGroupTitleLabel: 'notificationOlderGroupTitleLabel',
  notificationActiveGroupTitleLabel: 'notificationActiveGroupTitleLabel',
  reportBackgroundView: 'reportBackgroundView',
  reportStartDescriptionLabel: 'reportStartDescriptionLabel',
  reportStartButton: 'reportStartButton',
  reportPickReasonLabel: 'reportPickReasonLabel',
  reportReasonOptionLabel: 'reportReasonOptionLabel',
  reportChosenTitleLabel: 'reportChosenTitleLabel',
  reportChosenDescriptionLabel: 'reportChosenDescriptionLabel',
  reportChosenCancelLabel: 'reportChosenCancelLabel',
  reportThanksLabel: 'reportThanksLabel',
  reportThanksButton: 'reportThanksButton',
} as const;

export type AndroidCustomViewType =
  (typeof AndroidCustomUIViewType)[keyof typeof AndroidCustomUIViewType];

export const CustomUIViewType = {
  ...IOSCustomUIViewType,
  ...AndroidCustomUIViewType,
} as const;

export type VFCustomUIViewType = (typeof CustomUIViewType)[keyof typeof CustomUIViewType];

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
  | 'closeProfilePressed'
  | 'commentLiked'
  | 'commentDisliked';

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
    }
  | {
      type: 'commentLiked';
      content?: string;
    }
  | {
      type: 'commentDisliked';
      content?: string;
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
  theme?: VFCustomUITheme;
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
  theme?: VFCustomUITheme;
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
  theme?: VFCustomUITheme;
  colors?: ViafouraColors;
  onHeightChanged?: (event: { nativeEvent: NewCommentHeightChangedPayload }) => void;
  onAuthNeeded?: (event: { nativeEvent: NewCommentAuthNeededPayload }) => void;
  onCloseNewComment?: (event: { nativeEvent: Record<string, never> }) => void;
  onAction?: (event: { nativeEvent: ActionCallbackPayload }) => void;
  style?: StyleProp<ViewStyle>;
};

export type ConversationStarterHeightChangedPayload = PreviewCommentsHeightChangedPayload;
export type ConversationStarterAuthNeededPayload = PreviewCommentsAuthNeededPayload;
export type ConversationStarterOpenProfilePayload = PreviewCommentsOpenProfilePayload;
export type ConversationStarterNewCommentPayload = PreviewCommentsNewCommentPayload;

export type ConversationStarterViewProps = {
  containerId: string;
  articleUrl: string;
  articleTitle: string;
  articleSubtitle?: string;
  articleThumbnailUrl: string;
  syndicationKey?: string;
  title?: string;
  description?: string;
  minimumCommentCount?: number;
  darkMode?: boolean;
  theme?: VFCustomUITheme;
  colors?: ViafouraColors;
  onHeightChanged?: (event: { nativeEvent: ConversationStarterHeightChangedPayload }) => void;
  onAuthNeeded?: (event: { nativeEvent: ConversationStarterAuthNeededPayload }) => void;
  onOpenProfile?: (event: { nativeEvent: ConversationStarterOpenProfilePayload }) => void;
  onNewComment?: (event: { nativeEvent: ConversationStarterNewCommentPayload }) => void;
  onSeeMoreComments?: (event: { nativeEvent: Record<string, never> }) => void;
  onAction?: (event: { nativeEvent: ActionCallbackPayload }) => void;
  style?: StyleProp<ViewStyle>;
};

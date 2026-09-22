#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(PreviewCommentsManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(containerId, NSString)
RCT_EXPORT_VIEW_PROPERTY(authorId, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleUrl, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleSubtitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleThumbnailUrl, NSString)
RCT_EXPORT_VIEW_PROPERTY(syndicationKey, NSString)
RCT_EXPORT_VIEW_PROPERTY(darkMode, BOOL)
RCT_EXPORT_VIEW_PROPERTY(theme, NSString)
RCT_EXPORT_VIEW_PROPERTY(colors, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(adInterval, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(firstAdPosition, NSInteger)

RCT_EXPORT_VIEW_PROPERTY(onHeightChanged, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAuthNeeded, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onOpenProfile, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onNewComment, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onArticlePressed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAction, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAdSlotRequested, RCTDirectEventBlock)

@end

@interface RCT_EXTERN_MODULE(ConversationStarterManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(containerId, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleUrl, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleSubtitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleThumbnailUrl, NSString)
RCT_EXPORT_VIEW_PROPERTY(syndicationKey, NSString)
RCT_EXPORT_VIEW_PROPERTY(starterTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(starterDescription, NSString)
RCT_EXPORT_VIEW_PROPERTY(minimumCommentCount, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(darkMode, BOOL)
RCT_EXPORT_VIEW_PROPERTY(theme, NSString)
RCT_EXPORT_VIEW_PROPERTY(colors, NSDictionary)

RCT_EXPORT_VIEW_PROPERTY(onHeightChanged, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAuthNeeded, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onOpenProfile, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onNewComment, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSeeMoreComments, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAction, RCTDirectEventBlock)

@end

@interface RCT_EXTERN_MODULE(ViafouraAdSlotManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(position, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(adHeight, double)

@end

@interface RCT_EXTERN_MODULE(LiveQuestionsManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(containerId, NSString)
RCT_EXPORT_VIEW_PROPERTY(authorId, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleUrl, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleSubtitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(articleThumbnailUrl, NSString)
RCT_REMAP_VIEW_PROPERTY(title, liveQuestionsTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(sectionUUID, NSString)
RCT_EXPORT_VIEW_PROPERTY(focusedContentUUID, NSString)
RCT_EXPORT_VIEW_PROPERTY(limit, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(replyLimit, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(darkMode, BOOL)
RCT_EXPORT_VIEW_PROPERTY(theme, NSString)
RCT_EXPORT_VIEW_PROPERTY(colors, NSDictionary)

RCT_EXPORT_VIEW_PROPERTY(onHeightChanged, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAuthNeeded, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onOpenProfile, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAction, RCTDirectEventBlock)

@end

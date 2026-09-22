#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ViafouraCustomUI, NSObject)

RCT_EXTERN_METHOD(setCustomUIStyle:(NSString *)viewType
                  style:(NSDictionary *)style
                  theme:(nullable NSString *)theme)

RCT_EXTERN_METHOD(clearCustomUIStyle:(NSString *)viewType
                  theme:(nullable NSString *)theme)

@end

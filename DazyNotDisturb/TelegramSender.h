#import <Foundation/Foundation.h>

@interface TelegramSender : NSObject
+ (void)sendMessage:(NSString *)text token:(NSString *)token chatID:(NSString *)chatID;
@end

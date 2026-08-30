#import "TelegramSender.h"

@implementation TelegramSender

+ (void)sendMessage:(NSString *)text token:(NSString *)token chatID:(NSString *)chatID {
    if (token.length == 0 || chatID.length == 0) return;
    NSString *safeText = (text && text.length > 0) ? text : @"";
    if (safeText.length > 4000) {
        safeText = [safeText substringToIndex:4000];
    }

    NSString *urlStr = [NSString stringWithFormat:@"https://api.telegram.org/bot%@/sendMessage", token];
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) {
        NSLog(@"[DazyNotDisturb] Telegram URL parse fail");
        return;
    }

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    req.timeoutInterval = 10.0;
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *body = @{ @"chat_id": chatID, @"text": safeText };
    NSError *jsonErr = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonErr];
    if (!bodyData) {
        NSLog(@"[DazyNotDisturb] Telegram JSON encode fail: %@", jsonErr);
        return;
    }
    req.HTTPBody = bodyData;

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger code = [(NSHTTPURLResponse *)response statusCode];
            if (error) {
                NSLog(@"[DazyNotDisturb] Telegram send fail: %@", error.localizedDescription);
            } else if (code == 200) {
                NSLog(@"[DazyNotDisturb] Telegram send OK");
            } else {
                NSString *body = [[NSString alloc] initWithData:data ?: [NSData data] encoding:NSUTF8StringEncoding];
                NSLog(@"[DazyNotDisturb] Telegram send fail http=%ld body=%@", (long)code, body);
            }
        }];
    [task resume];
}

@end

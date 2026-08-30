#import <Foundation/Foundation.h>

static NSString *const kToggle = @"Disturb.Dazy.Pro/toggle";
static NSString *const kSuite = @"Disturb.Dazy.Pro";
static NSString *const kEnabled = @"DND_Enabled";

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: dndctl toggle|get\n");
            return 1;
        }
        NSString *cmd = [NSString stringWithUTF8String:argv[1]];
        if ([cmd isEqualToString:@"toggle"]) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                (__bridge CFStringRef)kToggle, NULL, NULL, YES);
        } else if ([cmd isEqualToString:@"get"]) {
            NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kSuite];
            BOOL on = [d boolForKey:kEnabled];
            printf("%d\n", on ? 1 : 0);
        } else {
            fprintf(stderr, "unknown command: %s\n", argv[1]);
            return 1;
        }
    }
    return 0;
}

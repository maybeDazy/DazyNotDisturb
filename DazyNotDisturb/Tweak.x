#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "BBServerBridge.h"
#import "TelegramSender.h"

static NSMutableArray<NSDictionary *> *storedBulletinSnapshots;
static NSUserDefaults *dndDefaults;

#define kSuite @"Disturb.Dazy.Pro"
#define kEnabled @"DND_Enabled"
#define kSelectedApps @"DND_SelectedApps"
#define kTgEnabled @"Telegram_Enabled"
#define kTgToken @"Telegram_BotToken"
#define kTgChat @"Telegram_ChatID"

static BOOL isEnabled() {
    return [dndDefaults boolForKey:kEnabled];
}

static BOOL appIsTarget(NSString *bundleID) {
    if (bundleID.length == 0) return NO;
    NSArray *selected = [dndDefaults arrayForKey:kSelectedApps];
    if (!selected || selected.count == 0) return YES;
    return [selected containsObject:bundleID];
}

static NSDictionary *snapshotBulletin(BBBulletin *b) {
    if (!b) return nil;
    NSString *sectionID = b.sectionID ? b.sectionID : @"";
    NSString *title     = b.title     ? b.title     : @"";
    NSString *message   = b.message   ? b.message   : @"";
    return @{
        @"sectionID": sectionID,
        @"title":     title,
        @"message":   message,
        @"date":      @([NSDate timeIntervalSinceReferenceDate])
    };
}

%hook BBServer

- (void)publishBulletin:(BBBulletin *)bulletin destinations:(unsigned long long)destinations {
    if (isEnabled() && appIsTarget(bulletin.sectionID)) {
        if (!storedBulletinSnapshots) storedBulletinSnapshots = [NSMutableArray new];
        NSDictionary *snap = snapshotBulletin(b);
        if (snap) [storedBulletinSnapshots addObject:snap];

        if ([dndDefaults boolForKey:kTgEnabled]) {
            NSString *text = [NSString stringWithFormat:@"[숨김 알림]\n앱: %@\n제목: %@\n내용: %@",
                               snap[@"sectionID"] ?: @"",
                               snap[@"title"]     ?: @"",
                               snap[@"message"]   ?: @""];
            [TelegramSender sendMessage:text
                                  token:[dndDefaults stringForKey:kTgToken]
                                 chatID:[dndDefaults stringForKey:kTgChat]];
        }
        return;
    }
    %orig;
}

%end

%hook SBBulletinBannerController

- (void)deactivateBulletinAnimated:(BOOL)animated {
    %orig;
}

%end

%ctor {
    dndDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuite];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
        NULL, NULL,
        CFSTR("Disturb.Dazy.Pro/toggle"), NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);

    NSLog(@"[DazyNotDisturb] loaded, enabled=%d", isEnabled());
}

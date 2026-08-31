#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "BBServerBridge.h"
#import "TelegramSender.h"

static NSMutableArray<NSDictionary *> *storedBulletinSnapshots;
static NSUserDefaults *dndDefaults;

#define kSuite @"Disturb.Dazy.Pro"
#define kEnabled @"DND_Enabled"
#define kTgEnabled @"Telegram_Enabled"
#define kTgToken @"Telegram_BotToken"
#define kTgChat @"Telegram_ChatID"

static BOOL isEnabled() {
    return [dndDefaults boolForKey:kEnabled];
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
    if (isEnabled() && bulletin) {
        NSDictionary *snap = snapshotBulletin(bulletin);
        if (snap) {
            if (!storedBulletinSnapshots) storedBulletinSnapshots = [NSMutableArray new];
            [storedBulletinSnapshots addObject:snap];
        }
        if ([dndDefaults boolForKey:kTgEnabled]) {
            NSString *text = [NSString stringWithFormat:@"[방해금지]\n앱: %@\n제목: %@\n내용: %@",
                               snap[@"sectionID"] ?: @"",
                               snap[@"title"]     ?: @"",
                               snap[@"message"]   ?: @""];
            [TelegramSender sendMessage:text
                                  token:[dndDefaults stringForKey:kTgToken]
                                 chatID:[dndDefaults stringForKey:kTgChat]];
        }
    }
    %orig;
}

%end

%ctor {
    dndDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuite];

    FILE *f = fopen("/var/mobile/dnd.log", "a");
    if (f) {
        fprintf(f, "[ctor] DazyNotDisturb loaded enabled=%d\n", isEnabled());
        fclose(f);
    }
    NSLog(@"[DazyNotDisturb] loaded, enabled=%d", isEnabled());
}

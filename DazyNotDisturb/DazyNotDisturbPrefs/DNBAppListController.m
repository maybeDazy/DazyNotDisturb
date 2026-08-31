#import "DNBAppListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/LSApplicationProxy.h>

@implementation DNBAppListController {
    NSMutableArray<NSString *> *_allBundleIDs;
    BOOL _loaded;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _allBundleIDs = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)specifiers {
    if (!_loaded) {
        [self loadInstalledApps];
        _loaded = YES;
    }
    NSMutableArray *specs = [NSMutableArray array];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];

    PSSpecifier *headerGroup = [PSSpecifier preferenceSpecifierNamed:@""
                                                                target:self
                                                                   set:nil
                                                                   get:nil
                                                                detail:nil
                                                                 cell:PSGroupCell
                                                                 edit:nil];
    [headerGroup setProperty:[NSString stringWithFormat:@"설치된 앱 %lu개. 끌 앱은 알림이 정상 표시됩니다.", (unsigned long)_allBundleIDs.count]
                      forKey:@"footerText"];
    [specs addObject:headerGroup];

    NSUInteger idx = 0;
    for (NSString *bid in _allBundleIDs) {
        @autoreleasepool {
            PSSpecifier *s = [PSSpecifier preferenceSpecifierNamed:bid
                                                              target:self
                                                                 set:@selector(setPreferenceValue:specifier:)
                                                                 get:@selector(readPreferenceValue:)
                                                              detail:nil
                                                               cell:PSSwitchCell
                                                               edit:nil];
            [s setProperty:bid forKey:@"label"];
            [s setProperty:[@"App_" stringByAppendingString:bid] forKey:@"key"];
            [s setProperty:@"Disturb.Dazy.Pro" forKey:@"defaults"];
            [s setProperty:@YES forKey:@"default"];
            BOOL on = [d boolForKey:[@"App_" stringByAppendingString:bid]];
            (void)on;
            [specs addObject:s];
        }
        idx++;
    }
    return specs;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];
    return @([d boolForKey:key]);
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];
    [d setObject:value forKey:key];
    [d synchronize];

    NSArray *arr = [d arrayForKey:@"DND_SelectedApps"] ?: @[];
    NSMutableArray *newArr = [arr mutableCopy];
    if (key && [key hasPrefix:@"App_"]) {
        NSString *bundleID = [key substringFromIndex:4];
        if ([value boolValue]) {
            if (![newArr containsObject:bundleID]) [newArr addObject:bundleID];
        } else {
            [newArr removeObject:bundleID];
        }
        [d setObject:newArr forKey:@"DND_SelectedApps"];
        [d synchronize];
    }
}

- (void)loadInstalledApps {
    Class wsClass = NSClassFromString(@"LSApplicationWorkspace");
    if (!wsClass) {
        NSLog(@"[DazyNotDisturb] LSApplicationWorkspace class not found");
        return;
    }
    @try {
        id ws = [wsClass performSelector:@selector(defaultWorkspace)];
        NSArray *apps = [ws performSelector:@selector(allInstalledApplications)];
        for (id proxy in apps) {
            NSString *bid = nil;
            if ([proxy respondsToSelector:@selector(bundleIdentifier)]) {
                bid = [proxy performSelector:@selector(bundleIdentifier)];
            }
            if (bid.length > 0) {
                [_allBundleIDs addObject:bid];
            }
        }
        [_allBundleIDs sortUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            return [a compare:b];
        }];
        NSLog(@"[DazyNotDisturb] loaded %lu apps", (unsigned long)_allBundleIDs.count);
    } @catch (NSException *e) {
        NSLog(@"[DazyNotDisturb] loadInstalledApps exception: %@", e);
    }
}

- (NSString *)navigationTitle {
    return @"대상 앱 선택";
}

@end

#import "DNBAppListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <CoreServices/CoreServices.h>
#import <MobileCoreServices/LSApplicationProxy.h>

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray *)allInstalledApplications;
@end

@interface LSApplicationProxy (AppList)
- (NSString *)bundleIdentifier;
- (NSString *)localizedName;
@end

@implementation DNBAppListController {
    NSMutableArray<NSString *> *_allBundleIDs;
    NSArray<NSString *> *_selectedBundleIDs;
    BOOL _loaded;
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"TargetApps" target:self];
    }
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];
    return [d objectForKey:key] ?: @NO;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];
    [d setObject:value forKey:key];
    [d synchronize];

    if (key && [key hasPrefix:@"App_"]) {
        NSString *bundleID = [key substringFromIndex:4];
        [self updateSelectedBundleIDs];
        NSMutableArray *arr = [d arrayForKey:@"DND_SelectedApps"] ? [[d arrayForKey:@"DND_SelectedApps"] mutableCopy] : [NSMutableArray array];
        if ([value boolValue]) {
            if (![arr containsObject:bundleID]) [arr addObject:bundleID];
        } else {
            [arr removeObject:bundleID];
        }
        [d setObject:arr forKey:@"DND_SelectedApps"];
        [d synchronize];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _allBundleIDs = [NSMutableArray array];
    [self loadInstalledApps];
    [self updateSelectedBundleIDs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_loaded) {
        [self updateSelectedBundleIDs];
        [self rebuildAppListSpecifiers];
    }
}

- (void)loadInstalledApps {
    Class wsClass = NSClassFromString(@"LSApplicationWorkspace");
    if (!wsClass) return;
    @try {
        id ws = [wsClass performSelector:@selector(defaultWorkspace)];
        NSArray *apps = [ws performSelector:@selector(allInstalledApplications)];
        for (id proxy in apps) {
            NSString *bid = nil;
            NSString *name = nil;
            if ([proxy respondsToSelector:@selector(bundleIdentifier)]) {
                bid = [proxy performSelector:@selector(bundleIdentifier)];
            }
            if ([proxy respondsToSelector:@selector(localizedName)]) {
                name = [proxy performSelector:@selector(localizedName)];
            }
            if (bid.length > 0 && name.length > 0) {
                [_allBundleIDs addObject:bid];
            }
        }
        [_allBundleIDs sortUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            return [a compare:b];
        }];
    } @catch (NSException *e) {
        NSLog(@"[DazyNotDisturb] loadInstalledApps exception: %@", e);
    }
}

- (void)updateSelectedBundleIDs {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];
    NSArray *arr = [d arrayForKey:@"DND_SelectedApps"];
    _selectedBundleIDs = arr ?: @[];
}

- (void)rebuildAppListSpecifiers {
    [self setValue:nil forKey:@"_specifiers"];
    _specifiers = nil;
    _specifiers = [self buildDynamicSpecifiers];
}

- (NSArray *)buildDynamicSpecifiers {
    NSMutableArray *specs = [NSMutableArray array];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];

    PSSpecifier *headerGroup = [PSSpecifier preferenceSpecifierNamed:@""
                                                                target:self
                                                                   set:NULL
                                                                   get:NULL
                                                                detail:Nil
                                                                 cell:PSGroupCell
                                                                 edit:Nil];
    [headerGroup setProperty:@"설치된 앱 목록입니다. 끄면 방해금지 모드와 무관하게 알림이 정상 표시됩니다." forKey:@"footerText"];
    [specs addObject:headerGroup];

    for (NSString *bid in _allBundleIDs) {
        PSSpecifier *s = [PSSpecifier preferenceSpecifierNamed:bid
                                                          target:self
                                                             set:@selector(setPreferenceValue:specifier:)
                                                             get:@selector(readPreferenceValue:)
                                                          detail:Nil
                                                           cell:PSSwitchCell
                                                           edit:Nil];
        [s setProperty:bid forKey:@"label"];
        [s setProperty:[@"App_" stringByAppendingString:bid] forKey:@"key"];
        [s setProperty:@"Disturb.Dazy.Pro" forKey:@"defaults"];
        BOOL on = [d boolForKey:[@"App_" stringByAppendingString:bid]];
        [s setProperty:@(on) forKey:@"default"];
        [specs addObject:s];
    }
    _loaded = YES;
    return specs;
}

- (NSString *)navigationTitle {
    return @"대상 앱 선택";
}

@end

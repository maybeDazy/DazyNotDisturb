#import "DNBAppListController.h"
#import <Preferences/PSSpecifier.h>

@implementation DNBAppListController

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
}

@end

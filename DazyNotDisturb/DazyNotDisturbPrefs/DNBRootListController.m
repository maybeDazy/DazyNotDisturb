#import "DNBRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation DNBRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)setSpecifierValueForPSID:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if ([key isEqualToString:@"DND_Enabled"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)@"Disturb.Dazy.Pro/stateChanged", NULL, NULL, YES);
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    id defaultValue = [specifier propertyForKey:@"default"];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];
    return [d objectForKey:key] ?: defaultValue;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:@"Disturb.Dazy.Pro"];
    [d setObject:value forKey:key];
    [d synchronize];
    [self setSpecifierValueForPSID:value specifier:specifier];
}

@end

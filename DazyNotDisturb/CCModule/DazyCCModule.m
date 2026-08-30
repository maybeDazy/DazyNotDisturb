#import <UIKit/UIKit.h>
#import <ControlCenterUIKit/ControlCenterUIKit.h>

static NSString *const kSuite = @"Disturb.Dazy.Pro";
static NSString *const kEnabled = @"DND_Enabled";
static NSString *const kToggle = @"Disturb.Dazy.Pro/toggle";
static NSString *const kStateChanged = @"Disturb.Dazy.Pro/stateChanged";

@interface DazyCCModuleViewController : UIViewController
- (instancetype)initWithSelected:(BOOL)selected;
- (void)setSelected:(BOOL)selected;
@end

@implementation DazyCCModuleViewController {
    BOOL _selected;
    UIView *_bgView;
    UILabel *_label;
}

- (instancetype)initWithSelected:(BOOL)selected {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _selected = selected;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (_bgView) {
        _bgView.backgroundColor = _selected ? [UIColor systemPurpleColor] : [UIColor systemGrayColor];
    }
    if (_label) {
        _label.text = _selected ? @"🔕" : @"🔔";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, 60, 60);
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _bgView.layer.cornerRadius = 14.0;
    _bgView.clipsToBounds = YES;
    _bgView.backgroundColor = _selected ? [UIColor systemPurpleColor] : [UIColor systemGrayColor];
    [self.view addSubview:_bgView];

    _label = [[UILabel alloc] initWithFrame:self.view.bounds];
    _label.text = _selected ? @"🔕" : @"🔔";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:32.0];
    _label.textColor = [UIColor whiteColor];
    [self.view addSubview:_label];
}

@end

@interface DazyCCModule : NSObject <CCUIContentModule>
@end

@implementation DazyCCModule {
    BOOL _selected;
    DazyCCModuleViewController *_vc;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kSuite];
        _selected = [d boolForKey:kEnabled];
        _vc = [[DazyCCModuleViewController alloc] initWithSelected:_selected];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge void *)self, dazyStateChangedCallback,
            CFSTR("Disturb.Dazy.Pro/stateChanged"), NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

static void dazyStateChangedCallback(CFNotificationCenterRef center, void *observer,
                                      CFStringRef name, const void *object,
                                      CFDictionaryRef userInfo) {
    DazyCCModule *self_ = (__bridge DazyCCModule *)observer;
    if (!self_) return;
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kSuite];
    BOOL on = [d boolForKey:kEnabled];
    self_->_selected = on;
    [self_->_vc setSelected:on];
}

- (UIViewController<CCUIContentModuleContentViewController> *)contentViewController {
    return (UIViewController<CCUIContentModuleContentViewController> *)_vc;
}

- (UIViewController *)backgroundViewController {
    return nil;
}

- (CGSize)moduleSizeForOrientation:(int)orientation {
    CGSize s = { 1, 1 };
    return s;
}

- (UIColor *)selectedColor {
    return [UIColor systemPurpleColor];
}

- (BOOL)isSelected {
    return _selected;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [_vc setSelected:selected];
}

- (void)dealloc {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge void *)self, CFSTR("Disturb.Dazy.Pro/stateChanged"), NULL);
}

- (void)buttonTapped:(id)arg {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kToggle, NULL, NULL, YES);
}

@end

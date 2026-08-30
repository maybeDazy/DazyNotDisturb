// BBServerBridge.h - BulletinBoard private interface
#import <Foundation/Foundation.h>

@interface BBBulletin : NSObject
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *bulletinID;
@end

@interface BBServer : NSObject
+ (id)sharedInstance;
- (void)publishBulletin:(BBBulletin *)bulletin destinations:(unsigned long long)destinations;
@end

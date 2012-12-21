#import <Foundation/Foundation.h>

@protocol BVMPingerDelegate;

@interface BVMPinger : NSObject

@property (nonatomic, weak) id<BVMPingerDelegate> delegate;

- (id)initWithHost:(NSString *)domainOrIp;

- (void)startPinging;
- (void)stopPinging;

@end

@protocol BVMPingerDelegate <NSObject>

- (void)pinger:(BVMPinger *)pinger didUpdateWithTime:(double)seconds;

@optional
- (void)pinger:(BVMPinger *)pinger didEncounterError:(NSError *)error;

@end

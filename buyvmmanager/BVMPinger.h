#import <Foundation/Foundation.h>

@protocol BVMPingerTimingDelegate;

@interface BVMPinger : NSObject

@property (nonatomic, weak) id<BVMPingerTimingDelegate> timingDelegate;

- (id)initWithHost:(NSString *)domainOrIp;

- (void)startPinging;
- (void)stopPinging;

@end

@protocol BVMPingerTimingDelegate <NSObject>

- (void)pinger:(BVMPinger *)pinger didUpdateWithTime:(double)seconds;

@end

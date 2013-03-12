#import <Foundation/Foundation.h>

@protocol BVMPingerDelegate;

@interface BVMPinger : NSObject

@property (nonatomic, weak) id<BVMPingerDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *domainOrIp;

- (id)initWithHost:(NSString *)domainOrIp;

- (void)startPinging;
- (void)stopPinging;

@end

@protocol BVMPingerDelegate <NSObject>

- (void)pinger:(BVMPinger *)pinger didUpdateWithAverageSeconds:(double)seconds;

@optional

/**
 *
 * note: Pinger stops when an error is encountered
 */
- (void)pinger:(BVMPinger *)pinger didEncounterError:(NSError *)error;

@end

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BVMServerActionStatus) {
    BVMServerActionStatusRebooted,
    BVMServerActionStatusBooted,
    BVMServerActionStatusShutdown
};

/**
 * Provides an asynchronous interface for performing actions
 * (boot/reboot/shutdown) on servers.
 *
 * For all methods, a nil error when the result block is called
 * means there was no detected error.
 */
@interface BVMServerAction : NSObject

+ (void)bootServer:(NSString *)serverName
         withBlock:(void (^)(BVMServerActionStatus status, NSError *error))resultBlock;

+ (void)rebootServer:(NSString *)serverName
           withBlock:(void (^)(BVMServerActionStatus status, NSError *error))resultBlock;

+ (void)shutdownServer:(NSString *)serverName
             withBlock:(void (^)(BVMServerActionStatus status, NSError *error))resultBlock;

@end

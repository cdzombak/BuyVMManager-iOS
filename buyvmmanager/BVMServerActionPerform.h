#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BVMServerActionStatus) {
    BVMServerActionStatusRebooted = 0,
    BVMServerActionStatusBooted,
    BVMServerActionStatusShutdown,
    BVMServerActionStatusIndeterminate
};

typedef NS_ENUM(NSUInteger, BVMServerAction) {
    BVMServerActionReboot = 0,
    BVMServerActionBoot,
    BVMServerActionShutdown
};

@interface BVMServerActionPerform : NSObject

/**
 * Provides an asynchronous interface for performing actions
 * (boot/reboot/shutdown) on servers.
 *
 * For all methods, a nil error when the result block is called
 * means there was no detected error.
 */
+ (void)performAction:(BVMServerAction)action
            forServer:(NSString *)serverName
         withBlock:(void (^)(BVMServerActionStatus status, NSError *error))resultBlock;

@end

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BVMServerStatus) {
    BVMServerStatusOffline = 0,
    BVMServerStatusOnline
};

/**
 * Provides methods to asynchronously query server status/info, and
 * a representation of that status.
 */
@interface BVMServerInfo : NSObject

/**
 * Provides an asynchronous interface to query for info about a server
 *
 * @param serverName
 *            name assigned to the server by the user. Used to identify
 *            the server in user defaults.
 *
 * @param resultBlock
 *            block called with results of the query. No error occurred
 *            if `error` is nil.
 */
+ (void)requestInfoForServer:(NSString *)serverName
                   withBlock:(void (^)(BVMServerInfo * info, NSError *error))resultBlock;

/**
 * Provides an asynchronous interface to query status of a server
 *
 * @param serverName
 *            name assigned to the server by the user. Used to identify
 *            the server in user defaults.
 *
 * @param resultBlock
 *            block called with results of the query. No error occurred
 *            if `error` is nil.
 */
+ (void)requestStatusForServer:(NSString *)serverName
                     withBlock:(void (^)(BVMServerStatus status, NSError *error))resultBlock;

#pragma mark Server Info

/**
 * Server status
 */
@property (nonatomic, readonly, assign) BVMServerStatus status;

/**
 * Server hostname
 */
@property (nonatomic, readonly, strong) NSString *hostname;

/**
 * "Main" IP for the server
 */
@property (nonatomic, readonly, strong) NSString *mainIpAddress;

/**
 * `NSString`s of all IPs for the server
 */
@property (nonatomic, readonly, strong) NSArray *ipAddresses;

/**
 * Total HDD capacity, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger hddTotal;

/**
 * HDD used, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger hddUsed;

/**
 * HDD free, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger hddFree;

/**
 * HDD percent used
 */
@property (nonatomic, readonly, assign) NSUInteger hddPercentUsed;

/**
 * Total memory, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger memTotal;

/**
 * Memory used, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger memUsed;

/**
 * Memory free, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger memFree;

/**
 * Memory percent used
 */
@property (nonatomic, readonly, assign) NSUInteger memPercentUsed;

/**
 * Total bandwidth available, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger bwTotal;

/**
 * Bandwidth used, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger bwUsed;

/**
 * Bandwidth free, in bytes
 */
@property (nonatomic, readonly, assign) NSUInteger bwFree;

/**
 * Bandwidth percent used
 */
@property (nonatomic, readonly, assign) NSUInteger bwPercentUsed;

@end

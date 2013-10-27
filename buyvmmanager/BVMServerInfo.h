#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BVMServerStatus) {
    BVMServerStatusOffline = 0,
    BVMServerStatusOnline,
    BVMServerStatusIndeterminate
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
+ (void)requestInfoForServerId:(NSString *)serverId
                     withBlock:(void (^)(BVMServerInfo * info, NSError *error))resultBlock;

#pragma mark Server Info

/**
 * Server status
 */
@property (nonatomic, assign) BVMServerStatus status;

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
@property (nonatomic, readonly, assign) long long hddTotal;

/**
 * HDD used, in bytes
 */
@property (nonatomic, readonly, assign) long long hddUsed;

/**
 * HDD free, in bytes
 */
@property (nonatomic, readonly, assign) long long hddFree;

/**
 * HDD percent used
 */
@property (nonatomic, readonly, assign) NSUInteger hddPercentUsed;

/**
 * Total memory, in bytes
 */
@property (nonatomic, readonly, assign) long long memTotal;

/**
 * Memory used, in bytes
 */
@property (nonatomic, readonly, assign) long long memUsed;

/**
 * Memory free, in bytes
 */
@property (nonatomic, readonly, assign) long long memFree;

/**
 * Memory percent used
 */
@property (nonatomic, readonly, assign) NSUInteger memPercentUsed;

/**
 * Total bandwidth available, in bytes
 */
@property (nonatomic, readonly, assign) long long bwTotal;

/**
 * Bandwidth used, in bytes
 */
@property (nonatomic, readonly, assign) long long bwUsed;

/**
 * Bandwidth free, in bytes
 */
@property (nonatomic, readonly, assign) long long bwFree;

/**
 * Bandwidth percent used
 */
@property (nonatomic, readonly, assign) NSUInteger bwPercentUsed;

@end

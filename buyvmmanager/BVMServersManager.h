#import <Foundation/Foundation.h>

static NSString * const kBVMServerKeyAPIKey = @"key";
static NSString * const kBVMServerKeyAPIHash = @"hash";

@interface BVMServersManager : NSObject

/**
 * Returns a dictionary mapping server IDs to names
 */
+ (NSDictionary *)servers;

/**
 * Returns a dictionary containing the credentials for
 * the given server ID.
 *
 * If successful, the dictionary will contain the keys
 * `kBVMServerKeyAPIKey` and `kBVMServerKeyAPIHash`
 */
+ (NSDictionary *)credentialsForServerId:(NSString *)serverId;

/**
 * Saves the details for the given server.
 *
 * If ID is `nil`, create a new server. Otherwise, update
 * the server with the given ID.
 */
+ (BOOL)saveServerId:(NSString *)serverId name:(NSString *)serverName key:(NSString *)key hash:(NSString *)hash;

+ (void)removeServerId:(NSString *)serverId;

@end

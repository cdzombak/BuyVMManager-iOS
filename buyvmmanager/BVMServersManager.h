#import <Foundation/Foundation.h>

static NSString * const kBVMServerKeyAPIKey = @"key";
static NSString * const kBVMServerKeyAPIHash = @"hash";

@interface BVMServersManager : NSObject

+ (NSArray *)serverNames;
+ (NSDictionary *)credentialsForServer:(NSString *)serverName;

+ (BOOL)saveServerName:(NSString *)name key:(NSString *)key hash:(NSString *)hash;
+ (void)removeServerNamed:(NSString *)serverName;

@end

#import "BVMServersManager.h"
#import "KCMutableDictionary.h"

static NSString * const kBVMUserDefaultsServersKey = @"servers";

@implementation BVMServersManager

+ (NSDictionary *)servers
{
    NSDictionary *servers = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBVMUserDefaultsServersKey];
    if (!servers) servers = @{};

    return servers;
}

+ (NSDictionary *)credentialsForServerId:(NSString *)serverId
{
    NSString *credentialKey = [BVMServersManager keychainDictionaryNameForServerId:serverId];
    NSDictionary *credentials = [KCMutableDictionary dictionaryWithName:credentialKey];

    return credentials;
}

+ (BOOL)saveServerId:(NSString *)serverId name:(NSString *)serverName key:(NSString *)key hash:(NSString *)hash
{
    NSDictionary *servers = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBVMUserDefaultsServersKey];

    NSMutableDictionary *mutableServers = [servers mutableCopy];
    if (!mutableServers) mutableServers = [NSMutableDictionary dictionary];

    if (!serverId) {
        serverId = [BVMServersManager generateUUID];
    }

    if (mutableServers[serverId]) {
        [mutableServers removeObjectForKey:serverId];
    }

    mutableServers[serverId] = serverName;

    NSString *credentialKey = [BVMServersManager keychainDictionaryNameForServerId:serverId];
    KCMutableDictionary *credentials = [KCMutableDictionary dictionaryWithName:credentialKey];
    credentials[kBVMServerKeyAPIKey] = key;
    credentials[kBVMServerKeyAPIHash] = hash;

    [[NSUserDefaults standardUserDefaults] setObject:mutableServers forKey:kBVMUserDefaultsServersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+ (void)removeServerId:(NSString *)serverId
{
    NSDictionary *servers = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBVMUserDefaultsServersKey];
    if (!servers[serverId]) return;

    NSMutableDictionary *mutableServers = [servers mutableCopy];
    [mutableServers removeObjectForKey:serverId];

    [[NSUserDefaults standardUserDefaults] setObject:mutableServers forKey:kBVMUserDefaultsServersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)keychainDictionaryNameForServerId:(NSString *)serverId
{
    return [NSString stringWithFormat:@"server_%@", serverId];
}

+(NSString *)generateUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    return uuidString;
}

@end

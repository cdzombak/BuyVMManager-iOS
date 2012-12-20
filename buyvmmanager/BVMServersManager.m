#import "BVMServersManager.h"

static NSString * const kBVMUserDefaultsServersKey = @"servers";

@implementation BVMServersManager

+ (NSArray *)serverNames
{
    NSDictionary *servers = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBVMUserDefaultsServersKey];

    NSArray *serverNames;
    if (!servers) serverNames = [NSArray array];
    else serverNames = [servers allKeys];

    return serverNames;
}

+ (NSDictionary *)credentialsForServer:(NSString *)serverName
{
    NSDictionary *servers = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBVMUserDefaultsServersKey];

    NSDictionary *credentials;
    credentials = [servers objectForKey:serverName];
    if (!credentials) credentials = nil;

    return credentials;
}

+ (BOOL)saveServerName:(NSString *)serverName key:(NSString *)key hash:(NSString *)hash
{
    NSDictionary *servers = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBVMUserDefaultsServersKey];
    if ([servers objectForKey:serverName] != nil) return NO;

    NSMutableDictionary *mutableServers = [servers mutableCopy];
    [mutableServers setObject:@{
        kBVMServerKeyAPIKey: key,
         kBVMServerKeyAPIHash: hash
     } forKey:serverName];

    [[NSUserDefaults standardUserDefaults] setObject:mutableServers forKey:kBVMUserDefaultsServersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+ (void)removeServerNamed:(NSString *)serverName
{
    NSDictionary *servers = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBVMUserDefaultsServersKey];
    if ([servers objectForKey:serverName] == nil) return;

    NSMutableDictionary *mutableServers = [servers mutableCopy];
    [mutableServers removeObjectForKey:serverName];

    [[NSUserDefaults standardUserDefaults] setObject:mutableServers forKey:kBVMUserDefaultsServersKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

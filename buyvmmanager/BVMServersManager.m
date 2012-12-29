#import "BVMServersManager.h"
#include "NSArray+BVMArrayExtensions.h"
#import "KCMutableDictionary.h"

static NSString * const kBVMUserDefaultsServerNamesKey = @"serverNames";

@implementation BVMServersManager

+ (NSArray *)serverNames
{
    NSArray *serverNames = [[NSUserDefaults standardUserDefaults] arrayForKey:kBVMUserDefaultsServerNamesKey];
    if (!serverNames) serverNames = [NSArray array];

    return serverNames;
}

+ (NSDictionary *)credentialsForServer:(NSString *)serverName
{
    NSString *credentialKey = [BVMServersManager keychainDictionaryNameForServer:serverName];
    NSDictionary *credentials = [KCMutableDictionary dictionaryWithName:credentialKey];

    return credentials;
}

+ (BOOL)saveServerName:(NSString *)serverName key:(NSString *)key hash:(NSString *)hash
{
    NSArray *serverNames = [[NSUserDefaults standardUserDefaults] arrayForKey:kBVMUserDefaultsServerNamesKey];
    if (serverNames && [serverNames bvm_indexOfString:serverName] != NSNotFound) return NO;

    NSMutableArray *mutableServerNames = [serverNames mutableCopy];
    if (!mutableServerNames) mutableServerNames = [NSMutableArray array];
    [mutableServerNames addObject:serverName];

    NSString *credentialKey = [BVMServersManager keychainDictionaryNameForServer:serverName];
    KCMutableDictionary *credentials = [KCMutableDictionary dictionaryWithName:credentialKey];
    [credentials setObject:key forKey:kBVMServerKeyAPIKey];
    [credentials setObject:hash forKey:kBVMServerKeyAPIHash];

    [[NSUserDefaults standardUserDefaults] setObject:mutableServerNames forKey:kBVMUserDefaultsServerNamesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+ (void)removeServerNamed:(NSString *)serverName
{
    NSArray *serverNames = [[NSUserDefaults standardUserDefaults] arrayForKey:kBVMUserDefaultsServerNamesKey];
    NSUInteger serverNameIndex = [serverNames bvm_indexOfString:serverName];
    if (serverNameIndex == NSNotFound) return;

    NSMutableArray *mutableServerNames = [serverNames mutableCopy];
    [mutableServerNames removeObjectAtIndex:serverNameIndex];

    [[NSUserDefaults standardUserDefaults] setObject:mutableServerNames forKey:kBVMUserDefaultsServerNamesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)keychainDictionaryNameForServer:(NSString *)server
{
    return [NSString stringWithFormat:@"server_%@", server];
}

@end

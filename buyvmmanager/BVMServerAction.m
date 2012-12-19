#import "BVMServerAction.h"

@implementation BVMServerAction

+ (void)bootServer:(NSString *)serverName
         withBlock:(void (^)(BVMServerActionStatus, NSError *))resultBlock
{
    #warning TODO CDZ
}

+ (void)rebootServer:(NSString *)serverName
           withBlock:(void (^)(BVMServerActionStatus, NSError *))resultBlock
{
    #warning TODO CDZ
}

+ (void)shutdownServer:(NSString *)serverName
             withBlock:(void (^)(BVMServerActionStatus, NSError *))resultBlock
{
    #warning TODO CDZ
}

@end

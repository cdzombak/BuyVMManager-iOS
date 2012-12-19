#import "BVMServerInfo.h"

@interface BVMServerInfo ()

// Redefine properties internally as readwrite
@property (nonatomic, readwrite, assign) BVMServerStatus status;
@property (nonatomic, readwrite, strong) NSString *hostname;
@property (nonatomic, readwrite, strong) NSString *mainIpAddress;
@property (nonatomic, readwrite, strong) NSArray *ipAddresses;
@property (nonatomic, readwrite, assign) NSUInteger hddTotal;
@property (nonatomic, readwrite, assign) NSUInteger hddUsed;
@property (nonatomic, readwrite, assign) NSUInteger hddFree;
@property (nonatomic, readwrite, assign) NSUInteger hddPercentUsed;
@property (nonatomic, readwrite, assign) NSUInteger memTotal;
@property (nonatomic, readwrite, assign) NSUInteger memUsed;
@property (nonatomic, readwrite, assign) NSUInteger memFree;
@property (nonatomic, readwrite, assign) NSUInteger memPercentUsed;
@property (nonatomic, readwrite, assign) NSUInteger bwTotal;
@property (nonatomic, readwrite, assign) NSUInteger bwUsed;
@property (nonatomic, readwrite, assign) NSUInteger bwFree;
@property (nonatomic, readwrite, assign) NSUInteger bwPercentUsed;

@end

@implementation BVMServerInfo

+ (void)requestInfoForServer:(NSString *)serverName
                   withBlock:(void (^)(BVMServerInfo *, NSError *))resultBlock
{
    #warning TODO CDZ
}

+ (void) requestStatusForServer:(NSString *)serverName
                      withBlock:(void (^)(BVMServerStatus, NSError *))resultBlock
{
    #warning TODO CDZ
}

@end

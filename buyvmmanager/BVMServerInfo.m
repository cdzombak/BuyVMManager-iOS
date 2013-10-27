#import "BVMServerInfo.h"
#import "BVMAPIClient.h"
#import "BVMAPIResponseParser.h"
#import "BVMServersManager.h"
#import "NSError+BVMErrors.h"

static const NSTimeInterval kBVMInfoTimeoutInterval = 20.0;

@interface BVMServerInfo ()

// Redefine properties internally as readwrite
@property (nonatomic, readwrite, strong) NSString *hostname;
@property (nonatomic, readwrite, strong) NSString *mainIpAddress;
@property (nonatomic, readwrite, strong) NSArray *ipAddresses;
@property (nonatomic, readwrite, assign) long long hddTotal;
@property (nonatomic, readwrite, assign) long long hddUsed;
@property (nonatomic, readwrite, assign) long long hddFree;
@property (nonatomic, readwrite, assign) NSUInteger hddPercentUsed;
@property (nonatomic, readwrite, assign) long long memTotal;
@property (nonatomic, readwrite, assign) long long memUsed;
@property (nonatomic, readwrite, assign) long long memFree;
@property (nonatomic, readwrite, assign) NSUInteger memPercentUsed;
@property (nonatomic, readwrite, assign) long long bwTotal;
@property (nonatomic, readwrite, assign) long long bwUsed;
@property (nonatomic, readwrite, assign) long long bwFree;
@property (nonatomic, readwrite, assign) NSUInteger bwPercentUsed;

@end

@implementation BVMServerInfo

+ (void)requestInfoForServerId:(NSString *)serverId
                       success:(void (^)(BVMServerInfo *info))successBlock
                         error:(void (^)(NSError *error))errorBlock
                    completion:(void(^)())completionBlock
{
    if (!completionBlock) completionBlock = ^(){};
    if (!successBlock) successBlock = ^(BVMServerInfo *a){};
    if (!errorBlock) errorBlock = ^(NSError *a){};

    NSDictionary *credentials = [BVMServersManager credentialsForServerId:serverId];
    NSDictionary *params = @{
        @"key": credentials[kBVMServerKeyAPIKey] != nil ? credentials[kBVMServerKeyAPIKey] : @"",
        @"hash": credentials[kBVMServerKeyAPIHash] != nil ? credentials[kBVMServerKeyAPIHash] : @"",
        @"action": @"info",
        @"ipaddr": @"true",
        @"status": @"true",
        @"hdd": @"true",
        @"mem": @"true",
        @"bw": @"true",
    };

    void (^internalFailureBlock)(NSError *) = ^(NSError *error) {
        if (!error) error = [NSError bvm_indeterminateAPIError];
        errorBlock(error);
    };

    [[BVMAPIClient sharedClient] getPath:kBuyVMAPIPath
                              parameters:params
                         timeoutInterval:kBVMInfoTimeoutInterval
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     NSError __autoreleasing *error = nil;
                                     BVMAPIResponseParser *parser = [[BVMAPIResponseParser alloc] initWithAPIResponse:responseObject error:&error];
                                     if (parser) {
                                         error = [parser apiError];
                                     }
                                     if (error) {
                                         internalFailureBlock(error);
                                     }
                                     else {
                                         BVMServerInfo *info = [BVMServerInfo infoFromParser:parser];
                                         successBlock(info);
                                     }
                                     completionBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     internalFailureBlock(error);
                                     completionBlock();
                                 }];
}

+ (BVMServerInfo *)infoFromParser:(BVMAPIResponseParser *)parser
{
    BVMServerInfo *info = [[BVMServerInfo alloc] init];
    
    info.status = [BVMAPIResponseParser serverStatusFromApiString:[parser stringForNode:@"vmstat"]];

    if (info.status == BVMServerStatusIndeterminate) {
        return info;
    }

    info.hostname = [parser stringForNode:@"hostname"];
    info.mainIpAddress = [parser stringForNode:@"ipaddress"];

    NSArray *bwInfo = [[parser stringForNode:@"bw"] componentsSeparatedByString:@","];
    if (bwInfo.count == 4) {
        info.bwTotal = [bwInfo[0] longLongValue];
        info.bwUsed  = [bwInfo[1] longLongValue];
        info.bwFree  = [bwInfo[2] longLongValue];
        info.bwPercentUsed = [bwInfo[3] intValue];
    }

    if (info.status == BVMServerStatusOffline) {
        return info;
    }

    info.ipAddresses = [[parser stringForNode:@"ipaddr"] componentsSeparatedByString:@","];

    // format for remaining fields: total,used,free,percentused
    
    NSArray *hddInfo = [[parser stringForNode:@"hdd"] componentsSeparatedByString:@","];
    if (hddInfo.count == 4) {
        info.hddTotal = [hddInfo[0] longLongValue];
        info.hddUsed  = [hddInfo[1] longLongValue];
        info.hddFree  = [hddInfo[2] longLongValue];
        info.hddPercentUsed = [hddInfo[3] intValue];
    }

    NSArray *memInfo = [[parser stringForNode:@"mem"] componentsSeparatedByString:@","];
    if (memInfo.count == 4) {
        info.memTotal = [memInfo[0] longLongValue];
        info.memUsed  = [memInfo[1] longLongValue];
        info.memFree  = [memInfo[2] longLongValue];
        info.memPercentUsed = [memInfo[3] intValue];
    }

    return info;
}

#pragma mark Property Overrides

- (NSArray *)ipAddresses
{
    if (!_ipAddresses) {
        _ipAddresses = @[];
    }
    return _ipAddresses;
}

@end

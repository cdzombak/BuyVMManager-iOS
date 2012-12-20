#import "BVMServerInfo.h"
#import "BVMAPIClient.h"
#import "BVMServersManager.h"
#import "NSArray+BVMArrayExtensions.h"

#import "DDXML.h"

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
    NSDictionary *credentials = [BVMServersManager credentialsForServer:serverName];
    NSDictionary *params = @{
        @"key": credentials[kBVMServerKeyAPIKey],
        @"hash": credentials[kBVMServerKeyAPIHash],
        @"action": @"info",
        @"ipaddr": @"true",
        @"status": @"true",
        @"hdd": @"true",
        @"mem": @"true",
        @"bw": @"true",
    };
    [[BVMAPIClient sharedClient] getPath:kBuyVMAPIPath
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     // todo refactor the fuck out of this!!! maybe extract this munging and parsing into my own operation subclass.
                                     NSString *resp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                     resp = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><root>%@</root>", resp]; // fuck this api
                                     BVMServerInfo *info = [BVMServerInfo infoFromXml:resp];
                                     if (resultBlock) resultBlock(info, nil);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (!error) error = [NSError errorWithDomain:@"com.cdz.buyvmmanager"
                                                                             code:1
                                                                         userInfo:@{NSLocalizedDescriptionKey: @"The API request failed without additional information."}
                                                          ];
                                     if (resultBlock) resultBlock(nil, error);
                                 }];
}

+ (void) requestStatusForServer:(NSString *)serverName
                      withBlock:(void (^)(BVMServerStatus, NSString *hostname, NSString *ip, NSError *))resultBlock
{
    NSDictionary *credentials = [BVMServersManager credentialsForServer:serverName];
    NSDictionary *params = @{
        @"key": credentials[kBVMServerKeyAPIKey],
        @"hash": credentials[kBVMServerKeyAPIHash],
        @"action": @"status"
    };
    [[BVMAPIClient sharedClient] getPath:kBuyVMAPIPath
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     // todo refactor the fuck out of this!!! maybe extract this munging and parsing into my own operation subclass.
                                     NSString *resp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                     resp = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><root>%@</root>", resp]; // fuck this api

                                     NSError *xmlerror = nil;
                                     DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:resp options:0 error:&xmlerror];
                                     // todo: check and deal with error

                                     BVMServerStatus status = [BVMServerInfo statusFromApiString:[BVMServerInfo _parseStringForNode:@"vmstat" fromXml:doc]];
                                     NSString *hostname = [BVMServerInfo _parseStringForNode:@"hostname" fromXml:doc];
                                     NSString *ip = [BVMServerInfo _parseStringForNode:@"ipaddress" fromXml:doc];

                                     if (resultBlock) resultBlock(status, hostname, ip, nil);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (!error) error = [NSError errorWithDomain:@"com.cdz.buyvmmanager"
                                                                             code:1
                                                                         userInfo:@{NSLocalizedDescriptionKey: @"The API request failed without additional information."}
                                                          ];
                                     if (resultBlock) resultBlock(BVMServerStatusOffline, nil, nil, error);
                                 }];
}

+ (BVMServerInfo *)infoFromXml:(NSString *)apiResponse
{
    BVMServerInfo *info = [[BVMServerInfo alloc] init];
    NSError *error = nil;
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:apiResponse options:0 error:&error];
    // todo: check and deal with error

    info.status = [BVMServerInfo statusFromApiString:[BVMServerInfo _parseStringForNode:@"vmstat" fromXml:doc]];
    info.hostname = [BVMServerInfo _parseStringForNode:@"hostname" fromXml:doc];
    info.mainIpAddress = [BVMServerInfo _parseStringForNode:@"ipaddress" fromXml:doc];
    info.ipAddresses = [[BVMServerInfo _parseStringForNode:@"ipaddr" fromXml:doc] componentsSeparatedByString:@","];

    // total,used,free,percentused
    NSArray *hddInfo = [[BVMServerInfo _parseStringForNode:@"hdd" fromXml:doc] componentsSeparatedByString:@","];
    if (hddInfo.count == 4) {
        info.hddTotal = [hddInfo[0] intValue];
        info.hddUsed  = [hddInfo[1] intValue];
        info.hddFree  = [hddInfo[2] intValue];
        info.hddPercentUsed = [hddInfo[3] intValue];
    }

    NSArray *memInfo = [[BVMServerInfo _parseStringForNode:@"mem" fromXml:doc] componentsSeparatedByString:@","];
    if (memInfo.count == 4) {
        info.memTotal = [memInfo[0] intValue];
        info.memUsed  = [memInfo[1] intValue];
        info.memFree  = [memInfo[2] intValue];
        info.memPercentUsed = [memInfo[3] intValue];
    }

    NSArray *bwInfo = [[BVMServerInfo _parseStringForNode:@"bw" fromXml:doc] componentsSeparatedByString:@","];
    if (bwInfo.count == 4) {
        info.bwTotal = [bwInfo[0] intValue];
        info.bwUsed  = [bwInfo[1] intValue];
        info.bwFree  = [bwInfo[2] intValue];
        info.bwPercentUsed = [bwInfo[3] intValue];
    }

    return info;
}

+ (NSString *)_parseStringForNode:(NSString *)nodeName fromXml:(DDXMLDocument *)xmlDoc
{
    NSError *error = nil;
    NSString *xpathQuery = [NSString stringWithFormat:@"//%@", nodeName];
    NSArray *nodes = [xmlDoc nodesForXPath:xpathQuery error:&error];
    // todo: check and deal with error
    DDXMLNode *textNode = [nodes bvm_firstObject];
    return [[textNode childAtIndex:0] stringValue];
}

+ (BVMServerStatus)statusFromApiString:(NSString *)statusString
{
    BVMServerStatus status = BVMServerStatusOffline;
    if ([statusString isEqualToString:@"online"]) {
        status = BVMServerStatusOnline;
    }
    return status;
}

@end

#import "BVMServerActionPerform.h"
#import "BVMAPIClient.h"
#import "NSArray+BVMArrayExtensions.h"
#import "DDXML.h"

@implementation BVMServerActionPerform

+ (void)performAction:(BVMServerAction)action
            forServer:(NSString *)serverName
            withBlock:(void (^)(BVMServerActionStatus status, NSError *error))resultBlock
{
    NSDictionary *params = @{
        @"action": [BVMServerActionPerform actionStringForAction:action]
    };
    [[BVMAPIClient sharedClient] getPath:kBuyVMAPIPath
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     // todo: extract this munging and parsing into my own operation subclass.
                                     NSString *resp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                     resp = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><root>%@</root>", resp]; // fuck this api
                                     BVMServerActionStatus status = [BVMServerActionPerform statusFromXml:resp];
                                     if (resultBlock) resultBlock(status, nil);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (!error) error = [NSError errorWithDomain:@"com.cdz.buyvmmanager"
                                                                             code:1
                                                                         userInfo:@{NSLocalizedDescriptionKey: @"The API request failed without additional information."}
                                                          ];
                                     if (resultBlock) resultBlock(BVMServerActionStatusIndeterminate, error);
                                 }];
}

+ (NSString *)actionStringForAction:(BVMServerAction)action
{
    switch (action) {
        case BVMServerActionBoot:
            return @"boot";
        case BVMServerActionReboot:
            return @"reboot";
        case BVMServerActionShutdown:
            return @"shutdown";
    }
    return nil;
}

+ (BVMServerActionStatus)statusFromApiString:(NSString *)string
{
    if ([string isEqualToString:@"rebooted"]) return BVMServerActionStatusRebooted;
    if ([string isEqualToString:@"booted"])   return BVMServerActionStatusBooted;
    if ([string isEqualToString:@"shutdown"]) return BVMServerActionStatusShutdown;
    return BVMServerActionStatusIndeterminate;
}

+ (BVMServerActionStatus)statusFromXml:(NSString*)apiXml
{
    NSError *error = nil;
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:apiXml options:0 error:&error];
    // todo: check and deal with error

    NSString *statusString = [BVMServerActionPerform _parseStringForNode:@"statusmsg" fromXml:doc];
    return [BVMServerActionPerform statusFromApiString:statusString];
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

@end

#import "BVMServerActionPerform.h"
#import "BVMAPIClient.h"
#import "BVMAPIResponseParser.h"
#import "BVMServersManager.h"
#import "NSError+BVMErrors.h"

@implementation BVMServerActionPerform

+ (void)performAction:(BVMServerAction)action
            forServer:(NSString *)serverName
            withBlock:(void (^)(BVMServerActionStatus status, NSError *error))resultBlock
{
    NSDictionary *credentials = [BVMServersManager credentialsForServer:serverName];
    NSDictionary *params = @{
        @"key": credentials[kBVMServerKeyAPIKey],
        @"hash": credentials[kBVMServerKeyAPIHash],
        @"action": [BVMServerActionPerform actionStringForAction:action]
    };

    void (^ failureBlock)(NSError *) = ^(NSError *error) {
        if (!error) error = [NSError bvm_indeterminateAPIError];
        if (resultBlock) resultBlock(BVMServerActionStatusIndeterminate, error);
    };

    [[BVMAPIClient sharedClient] getPath:kBuyVMAPIPath
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     NSError *error = nil;
                                     BVMAPIResponseParser *parser = [[BVMAPIResponseParser alloc] initWithAPIResponseString:responseObject error:&error];
                                     if (!parser) {
                                         failureBlock(error); return;
                                     }
                                     error = [parser apiError];
                                     if (error) {
                                         failureBlock(error); return;
                                     }
                                     
                                     BVMServerActionStatus status = [BVMServerActionPerform statusFromParser:parser];
                                     if (resultBlock) resultBlock(status, nil);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     failureBlock(error);
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

+ (BVMServerActionStatus)statusFromParser:(BVMAPIResponseParser *)parser
{
    NSString *statusString = [parser stringForNode:@"statusmsg"];
    return [BVMAPIResponseParser serverActionStatusFromApiString:statusString];
}

@end

#import "BVMHumanValueTransformer.h"
#include <netdb.h>

@implementation BVMHumanValueTransformer

+ (NSString *)shortErrorFromError:(NSError *)error
{
    // stolen from Apple SimplePing
    
    NSString *result = nil;
    NSNumber *failureNum;
    int failure;
    const char *failureStr;

    // Handle DNS errors as a special case.
    if ( [[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] && ([error code] == kCFHostErrorUnknown) ) {
        failureNum = [error userInfo][(id)kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = [failureNum intValue];
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = @(failureStr);
                }
            }
        }
    }

    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    return result;
}

@end

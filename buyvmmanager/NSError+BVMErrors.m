#import "NSError+BVMErrors.h"
#import "BVMErrorDomain.h"

@implementation NSError (BVMErrors)

+ (NSError *)bvm_indeterminateAPIError
{
    return [NSError errorWithDomain:kBVMErrorDomainName
                               code:BVMErrorAPINonSpecific
                           userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"The API request failed with no additional information.", nil) }];
}

@end

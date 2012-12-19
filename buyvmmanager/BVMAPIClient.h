#import "AFHTTPClient.h"

@interface BVMAPIClient : AFHTTPClient

+ (BVMAPIClient *)sharedClient;

@end

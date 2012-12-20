#import "AFHTTPClient.h"

static NSString * const kBuyVMAPIPath = @"command.php";

@interface BVMAPIClient : AFHTTPClient

+ (BVMAPIClient *)sharedClient;

@end

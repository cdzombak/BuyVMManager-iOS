#import "AFHTTPClient.h"

static NSString * const kBuyVMAPIPath = @"command.php";

@interface BVMAPIClient : AFHTTPClient

+ (BVMAPIClient *)sharedClient;

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
timeoutInterval:(NSTimeInterval)timeout
        success:(void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject ))success
        failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

@end

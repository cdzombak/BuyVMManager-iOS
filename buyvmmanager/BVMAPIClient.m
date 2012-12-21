#import "BVMAPIClient.h"

#import "AFXMLRequestOperation.h"

static NSString * const kBuyVMAPIBaseURLString = @"https://manage.buyvm.net/api/client";

@implementation BVMAPIClient

+ (BVMAPIClient *)sharedClient
{
    static BVMAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BVMAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kBuyVMAPIBaseURLString]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];

    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    // commented for now as BuyVM API seems to respond with text/html. le sigh.
    // [self setDefaultHeader:@"Accept" value:@"application/xml"];

    return self;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
timeoutInterval:(NSTimeInterval)timeout
        success:(void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject ))success
        failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure
{
    NSMutableURLRequest *request = [[BVMAPIClient sharedClient] requestWithMethod:@"GET" path:path parameters:parameters];
    request.timeoutInterval = timeout;

    AFHTTPRequestOperation *operation = [[BVMAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

@end

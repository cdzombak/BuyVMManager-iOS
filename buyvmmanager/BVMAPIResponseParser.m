#import "BVMAPIResponseParser.h"
#import "BVMErrorDomain.h"
#import "NSArray+BVMArrayExtensions.h"
#import "DDXML.h"

@interface BVMAPIResponseParser ()

@property (nonatomic, strong) DDXMLDocument *xmlDoc;

@end

@implementation BVMAPIResponseParser

#pragma mark Parsing helpers

+ (BVMServerStatus)serverStatusFromApiString:(NSString *)statusString
{
    if ([statusString isEqualToString:@"online"])  return BVMServerStatusOnline;
    if ([statusString isEqualToString:@"offline"]) return BVMServerStatusOffline;
    return BVMServerStatusIndeterminate;
}

+ (BVMServerActionStatus)serverActionStatusFromApiString:(NSString *)string
{
    if ([string isEqualToString:@"rebooted"]) return BVMServerActionStatusRebooted;
    if ([string isEqualToString:@"booted"])   return BVMServerActionStatusBooted;
    if ([string isEqualToString:@"shutdown"]) return BVMServerActionStatusShutdown;
    return BVMServerActionStatusIndeterminate;
}

#pragma mark Lifecycle

- (id)initWithAPIResponse:(NSData *)response error:(__autoreleasing NSError **)error
{
    self = [super init];
    if (self) {
        NSString *responseXml = [self cleanXMLResponseFromAPI:response];
        self.xmlDoc = [[DDXMLDocument alloc] initWithXMLString:responseXml options:0 error:error];
        if (!self.xmlDoc) self = nil;
    }
    return self;
}

#pragma mark XML

- (NSString *)cleanXMLResponseFromAPI:(NSData *)apiResponse
{
    NSString *resp = [[NSString alloc] initWithData:apiResponse encoding:NSUTF8StringEncoding];
    resp = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><root>%@</root>", resp]; // fuck this API
    return resp;
}

- (NSString *)stringForNode:(NSString *)nodeName
{
    NSString *xpathQuery = [NSString stringWithFormat:@"//%@", nodeName];
    NSArray *nodes = [self.xmlDoc nodesForXPath:xpathQuery error:NULL];
    if (!nodes || !nodes.count) return nil;
    DDXMLNode *textNode = [nodes bvm_firstObject];
    return [[textNode childAtIndex:0] stringValue];
}

- (NSError *)apiError
{
    NSString *status = [self stringForNode:@"status"];
    if (!status || ![status isEqualToString:@"error"]) return nil;

    NSString *statusMessage = [self stringForNode:@"statusmsg"];
    if (!statusMessage) statusMessage = NSLocalizedString(@"Indeterminate API Error", nil);

    return [NSError errorWithDomain:kBVMErrorDomainName
                               code:BVMErrorAPINonSpecific
                           userInfo:@{ NSLocalizedDescriptionKey: statusMessage }
            ];
}

@end

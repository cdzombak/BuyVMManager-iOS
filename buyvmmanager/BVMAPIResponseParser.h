#import <Foundation/Foundation.h>
#import "BVMServerInfo.h"
#import "BVMServerActionPerform.h"

@interface BVMAPIResponseParser : NSObject

+ (BVMServerStatus)serverStatusFromApiString:(NSString *)statusString;
+ (BVMServerActionStatus)serverActionStatusFromApiString:(NSString *)string;

/**
 * Create a response parser with the given API response.
 *
 * This method performs the necesary cleanup/validation of the malformed
 * XML response from the stupid API.
 *
 * returns nil if there was a parsing error or something.
 */
- (id)initWithAPIResponse:(NSData *)response error:(__autoreleasing NSError **)error;

/**
 * Returns the text content of the first XML node in the response with
 * the given name.
 */
- (NSString *)stringForNode:(NSString *)nodeName;

/**
 * Returns an `NSError` if there was an API error, nil otherwise.
 */
- (NSError *)apiError;

@end

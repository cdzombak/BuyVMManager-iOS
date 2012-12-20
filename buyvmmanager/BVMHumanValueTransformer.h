#import <Foundation/Foundation.h>

@interface BVMHumanValueTransformer : NSObject

+ (NSString *)humanSizeValueFromBytes:(long long)bytes;

@end

#import "BVMHumanValueTransformer.h"

@implementation BVMHumanValueTransformer

+ (NSString *)humanSizeValueFromBytes:(NSUInteger)bytes
{
    static NSString *tokens[] = { @"bytes", @"KiB", @"MiB", @"GiB", @"TiB", @"PiB", @"EiB", @"ZiB", @"YiB", @"err" };

    int multiplyFactor = 0;
    while (bytes > 1024) {
        bytes /= 1024;
        multiplyFactor++;
    }

    if (multiplyFactor > 9) multiplyFactor = 9;

    return [NSString stringWithFormat:@"%d %@", bytes, tokens[multiplyFactor]];
}

@end

#import "BVMHumanValueTransformer.h"

@implementation BVMHumanValueTransformer

+ (NSString *)humanSizeValueFromBytes:(long long)bytes
{
    static NSString *tokens[] = { @"bytes", @"KiB", @"MiB", @"GiB", @"TiB", @"PiB", @"EiB", @"ZiB", @"YiB", @"err" };

    double currentValue = (double)bytes;
    int multiplyFactor = 0;

    while (currentValue >= 1024.0) {
        currentValue /= 1024.0;
        multiplyFactor++;
    }

    if (multiplyFactor > 9) multiplyFactor = 9;

    return [NSString stringWithFormat:@"%.0f %@", currentValue, tokens[multiplyFactor]];
}

@end

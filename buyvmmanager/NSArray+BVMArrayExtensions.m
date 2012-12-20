#import "NSArray+BVMArrayExtensions.h"

@implementation NSArray (BVMArrayExtensions)

- (id)bvm_firstObject
{
    return (self.count > 0) ? self[0] : nil;
}

@end

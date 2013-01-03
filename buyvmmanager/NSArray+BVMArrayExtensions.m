#import "NSArray+BVMArrayExtensions.h"

@implementation NSArray (BVMArrayExtensions)

- (id)bvm_firstObject
{
    return (self.count > 0) ? self[0] : nil;
}

- (NSUInteger)bvm_indexOfString:(NSString *)searchString
{
    NSUInteger index = NSNotFound;
    for (NSUInteger i=0; i<self.count; ++i) {
        NSString *string = self[i];
        if ([string isEqualToString:searchString]) {
            index = i;
            break;
        }
    }
    return index;
}

@end

#import "NSArray+BVMArrayExtensions.h"

@implementation NSArray (BVMArrayExtensions)

- (id)bvm_firstObject
{
    return (self.count > 0) ? self[0] : nil;
}

- (NSUInteger)bvm_indexOfString:(NSString *)searchString
{
    return [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:searchString]) {
            if (stop != NULL) *stop = YES;
            return YES;
        }
        return NO;
    }];
}



@end

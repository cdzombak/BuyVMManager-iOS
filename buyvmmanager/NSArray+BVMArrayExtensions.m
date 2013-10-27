#import "NSArray+BVMArrayExtensions.h"

@implementation NSArray (BVMArrayExtensions)

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

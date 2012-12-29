#import <Foundation/Foundation.h>

@interface NSArray (BVMArrayExtensions)

- (id)bvm_firstObject;

- (NSUInteger)bvm_indexOfString:(NSString *)searchString;

@end

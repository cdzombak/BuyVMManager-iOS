#import "UIColor+BVMColors.h"

@implementation UIColor (BVMColors)

+ (UIColor *)bvm_onlineTextColor
{
    return [UIColor colorWithRed:80.0/255.0
                           green:136.0/255.0
                            blue:80.0/255.0
                           alpha:1.0];
}

+ (UIColor *)bvm_fieldErrorBackgroundColor
{
    return [UIColor colorWithRed:1.0
                           green:0.9
                            blue:0.9
                           alpha:1.0];
}

@end

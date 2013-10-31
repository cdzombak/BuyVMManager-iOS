#import "UIColor+BVMColors.h"

@implementation UIColor (BVMColors)

+ (UIColor *)bvm_onlineTextColor
{
    return [UIColor colorWithRed:80.0f/255.0f
                           green:136.0f/255.0f
                            blue:80.0f/255.0f
                           alpha:1.0];
}

+ (UIColor *)bvm_fieldErrorBackgroundColor
{
    return [UIColor colorWithRed:1.0
                           green:0.85f
                            blue:0.85f
                           alpha:1.0];
}

+ (UIColor *)bvm_tintColor
{
    return [UIColor colorWithRed:0.039f
                           green:0.525f
                            blue:0.110f
                           alpha:1.0f];
}

@end

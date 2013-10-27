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

+ (UIColor *)bvm_darkTableViewTextColor
{
    return [UIColor colorWithRed:76.0f/255.0f
                           green:86.0f/255.0f
                            blue:108.0f/255.0f
                           alpha:1.0];
}

+ (UIColor *)bvm_pullRefreshBackgroundColor
{
    return [UIColor colorWithWhite:232.0f/255.0f alpha:1.0];
}

+ (UIColor *)bvm_tableViewBackgroundColor
{
    return [UIColor colorWithWhite:222.0f/255.0f alpha:1.0];
}

+ (UIColor *)bvm_darkGrayTextShadowColor
{
    return [UIColor colorWithWhite:0.95f alpha:1.0];
}

@end

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
                           green:0.85
                            blue:0.85
                           alpha:1.0];
}

+ (UIColor *)bvm_darkTableViewTextColor
{
    return [UIColor colorWithRed:76.0/255.0
                           green:86.0/255.0
                            blue:108.0/255.0
                           alpha:1.0];
}

+ (UIColor *)bvm_pullRefreshBackgroundColor
{
    return [UIColor colorWithRed:226.0/255.0
                           green:229.0/255.0
                            blue:234.0/255.0
                           alpha:1.0];
}

@end

#import "BVMTextFieldTableViewCell.h"

@interface BVMTextFieldTableViewCell ()

@property (nonatomic, readwrite, strong) UITextField *textField;

@end

@implementation BVMTextFieldTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectZero];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.contentView addSubview:tf];
        self.textField = tf;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.textField.frame = CGRectMake(5, 0, self.contentView.bounds.size.width-8, self.contentView.bounds.size.height);
}

@end

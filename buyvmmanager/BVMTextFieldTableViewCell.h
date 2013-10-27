@interface BVMTextFieldTableViewCell : UITableViewCell

@property (nonatomic, readonly, strong) UITextField *textField;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

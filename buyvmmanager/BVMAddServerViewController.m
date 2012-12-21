#import "BVMAddServerViewController.h"
#import "BVMTextFieldTableViewCell.h"
#import "BVMServersManager.h"
#import "UIColor+BVMColors.h"

typedef NS_ENUM(NSUInteger, BVMAddServerTableViewRow) {
    BVMAddServerTableViewRowName = 0,
    BVMAddServerTableViewRowAPIKey,
    BVMAddServerTableViewRowAPIHash,
    BVMAddServerTableViewNumRows
};

@interface BVMAddServerViewController () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *serverNameField;
@property (nonatomic, weak) UITextField *apiKeyField;
@property (nonatomic, weak) UITextField *apiHashField;

@property (nonatomic, strong, readonly) UIView *footerView;

@end

@implementation BVMAddServerViewController

@synthesize footerView = _footerView;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Add VM", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.allowsSelection = NO;
    self.tableView.tableFooterView = self.footerView;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched)];
}

- (void)cancelButtonTouched
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doneButtonTouched
{
    [self saveData];
}

- (void)saveData
{
    NSArray *fields = @[self.serverNameField, self.apiKeyField, self.apiHashField];
    BOOL valid = YES;
    for (UITextField *field in fields) {
        if (!field.text || [field.text isEqualToString:@""]) {
            field.superview.superview.backgroundColor = [UIColor bvm_fieldErrorBackgroundColor];
            valid = NO;
        } else {
            field.superview.superview.backgroundColor = [UIColor whiteColor];
        }
    }

    if (!valid) return;

    NSArray *serverNames = [BVMServersManager serverNames];
    for (NSString *name in serverNames) {
        if ([name isEqualToString:self.serverNameField.text]) {
            self.serverNameField.superview.superview.backgroundColor = [UIColor bvm_fieldErrorBackgroundColor];
            valid = NO;
        } else {
            self.serverNameField.superview.superview.backgroundColor = [UIColor whiteColor];
        }
    }

    if (!valid) return;

    [BVMServersManager saveServerName:self.serverNameField.text key:self.apiKeyField.text hash:self.apiHashField.text];

    id afterAddTarget = self.afterAddTarget;
    if (afterAddTarget && self.afterAddAction && [afterAddTarget respondsToSelector:self.afterAddAction]) {
        [afterAddTarget performSelector:self.afterAddAction];
    }

    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BVMTextFieldTableViewCell *cell = [[BVMTextFieldTableViewCell alloc] initWithReuseIdentifier:@"Cell"];
    UITextField *tf = cell.textField;

    // set delegates to save
    if (indexPath.row == BVMAddServerTableViewRowName) {
        tf.placeholder = NSLocalizedString(@"Server Name", nil);
        tf.returnKeyType = UIReturnKeyNext;
        self.serverNameField = tf;
    }
    else if (indexPath.row == BVMAddServerTableViewRowAPIKey) {
        tf.placeholder = NSLocalizedString(@"API Key", nil);
        tf.returnKeyType = UIReturnKeyNext;
        self.apiKeyField = tf;
    }
    else if (indexPath.row == BVMAddServerTableViewRowAPIHash) {
        tf.placeholder = NSLocalizedString(@"API Hash", nil);
        tf.returnKeyType = UIReturnKeyDone;
        self.apiHashField = tf;
    }

    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.delegate = self;

    return cell;
}

#pragma mark UITableViewDelegate methods

// n/a

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.serverNameField) {
        [self.apiKeyField becomeFirstResponder];
        return NO;
    }
    if (textField == self.apiKeyField) {
        [self.apiHashField becomeFirstResponder];
        return NO;
    }
    if (textField == self.apiHashField) {
        [self.apiHashField resignFirstResponder];
        [self saveData];
        return NO;
    }
    return YES;
}

#pragma mark Property Overrides

- (UIView *)footerView
{
    if (!_footerView) {
        NSString *notes = NSLocalizedString(@"Server name may be anything you like.\nAPI Key and API Hash must be entered exactly as they appear in the VPS Control Panel at https://manage.buyvm.net/ clientapi.php.\nCopying these from elsewhere - an email, for example - is easiest.", nil);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.bounds.size.width-36, 130)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor bvm_darkTableViewTextColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1.0);
        label.text = notes;
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:15.0];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, label.bounds.size.height)];
        _footerView.backgroundColor = [UIColor clearColor];
        _footerView.autoresizesSubviews = YES;
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_footerView addSubview:label];
    }
    return _footerView;
}

@end

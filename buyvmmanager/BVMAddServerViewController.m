#import "BVMAddServerViewController.h"
#import "BVMTextFieldTableViewCell.h"
#import "BVMServersManager.h"

typedef NS_ENUM(NSUInteger, BVMAddServerTableViewRow) {
    BVMAddServerTableViewRowName = 0,
    BVMAddServerTableViewRowAPIKey,
    BVMAddServerTableViewRowAPIHash,
    BVMAddServerTableViewNumRows
};

@interface BVMAddServerViewController ()

@property (nonatomic, weak) UITextField *serverNameField;
@property (nonatomic, weak) UITextField *apiKeyField;
@property (nonatomic, weak) UITextField *apiHashField;

@end

@implementation BVMAddServerViewController

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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched)];

    NSString *notes = NSLocalizedString(@"API Key and API Hash must be entered exactly as they appear in the VPS Control Panel. Copying these from elsewhere, an email for example, is easiest.\nServer name may be anything you like.", nil);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 90)];
    self.tableView.tableFooterView = label;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkTextColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1.0);
    label.text = notes;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14.0];
    label.backgroundColor = [UIColor clearColor];
}

- (void)cancelButtonTouched
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doneButtonTouched
{
    NSArray *fields = @[self.serverNameField, self.apiKeyField, self.apiHashField];
    BOOL valid = YES;
    for (UITextField *field in fields) {
        if (!field.text || [field.text isEqualToString:@""]) {
            field.superview.superview.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
            valid = NO;
        } else {
            field.superview.superview.backgroundColor = [UIColor whiteColor];
        }
    }

    NSArray *serverNames = [BVMServersManager serverNames];
    for (NSString *name in serverNames) {
        if ([name isEqualToString:self.serverNameField.text]) {
            self.serverNameField.superview.superview.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
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

#pragma mark UITableViewDataSource

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
        self.serverNameField = tf;
    }
    else if (indexPath.row == BVMAddServerTableViewRowAPIKey) {
        tf.placeholder = NSLocalizedString(@"API Key", nil);
        self.apiKeyField = tf;
    }
    else if (indexPath.row == BVMAddServerTableViewRowAPIHash) {
        tf.placeholder = NSLocalizedString(@"API Hash", nil);
        self.apiHashField = tf;
    }

    return cell;
}

#pragma mark - Table view delegate

// n/a

@end

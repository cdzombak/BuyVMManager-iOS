#import "BVMAboutSettingsViewController.h"
#import "UIColor+BVMColors.h"

typedef NS_ENUM(NSInteger, BVMAboutSettingsTableViewSections) {
    BVMAboutSettingsTableViewSectionContactSupport = 0,
    BVMAboutSettingsTableViewNumSections
};

@interface BVMAboutSettingsViewController ()

@property (nonatomic, strong, readonly) UIView *footerView;
@property (nonatomic, weak, readonly) UILabel *footerLabel;

@end

@implementation BVMAboutSettingsViewController

@synthesize footerLabel = _footerLabel,
            footerView = _footerView
            ;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // w/e
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"BuyVM Manager", nil);

    self.tableView.tableFooterView = self.footerView;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneButtonTapped)];

    self.contentSizeForViewInPopover = CGSizeMake(320, self.footerView.frame.origin.y + self.footerView.frame.size.height);
}

#pragma mark Interface actions

- (void)sendSupportEmail
{
    NSString *url = [NSString stringWithFormat:@"mailto:chris+bvmsupport@chrisdzombak.net?subject=BuyVM%%20Manager%%20Support%%20-%%20%@",
                     [self appVersion]];
    NSLog(@"%@", url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)doneButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Helpers

- (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return BVMAboutSettingsTableViewNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(section == BVMAboutSettingsTableViewSectionContactSupport);

    // only 1 section right now woo
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath.section == BVMAboutSettingsTableViewSectionContactSupport);
    NSParameterAssert(indexPath.row == 0);

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

    // right now, we only have one cell.
    // this code will be rewritten in shor torder when I add PIN support.

    cell.textLabel.text = NSLocalizedString(@"Email App Author", nil);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath.section == BVMAboutSettingsTableViewSectionContactSupport);
    NSParameterAssert(indexPath.row == 0);

    [self sendSupportEmail];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Property Overrides

- (UIView *)footerView
{
    if (!_footerView) {
        NSString *notes = [NSString stringWithFormat:NSLocalizedString(@"BuyVM Manager v%@", nil), [self appVersion]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.bounds.size.width-36, 40)];
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
        _footerLabel = label;

        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, label.bounds.size.height)];
        _footerView.backgroundColor = [UIColor clearColor];
        _footerView.autoresizesSubviews = YES;
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_footerView addSubview:label];
    }
    return _footerView;
}

@end

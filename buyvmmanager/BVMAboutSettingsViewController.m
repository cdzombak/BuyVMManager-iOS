#import "BVMAboutSettingsViewController.h"
#import "CDZLinkOpenManager.h"
#import "CDZBrowserSelectorViewController.h"
#import "UIColor+BVMColors.h"

typedef NS_ENUM(NSUInteger, BVMAboutSettingsTableViewSections) {
    BVMAboutSettingsTableViewSectionUsefulLinks = 0,
    BVMAboutSettingsTableViewSectionSupport,
    BVMAboutSettingsTableViewSectionSettings,
    BVMAboutSettingsTableViewNumSections
};

typedef NS_ENUM(NSUInteger, BVMAboutSettingsTableSupportRows) {
    BVMAboutSettingsTableSupportRowReportIssue = 0,
    BVMAboutSettingsTableSupportRowGithubProject,
    BVMAboutSettingsTableSupportNumRows
};

typedef NS_ENUM(NSUInteger, BVMAboutSettingsTableUsefulLinksRows) {
    BVMAboutSettingsTableUsefulLinksRowStallion = 0,
    BVMAboutSettingsTableUsefulLinksRowClientArea,
    BVMAboutSettingsTableUsefulLinksNumRows
};

typedef NS_ENUM(NSUInteger, BVMAboutSettingsTableSettingsRows) {
    BVMAboutSettingsTableSettingsRowBrowser = 0,
    BVMAboutSettingsTableSettingsNumRows
};

static NSString * BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewNumSections][2];
static NSUInteger BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewNumSections];

__attribute__((constructor)) static void __BVMAboutSettingsViewControllerTableConstantsInit(void)
{
    @autoreleasepool {
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionSupport][BVMAboutSettingsTableSupportRowReportIssue] = NSLocalizedString(@"Report Issue", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionSupport][BVMAboutSettingsTableSupportRowGithubProject] = NSLocalizedString(@"Github Project", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionUsefulLinks][BVMAboutSettingsTableUsefulLinksRowStallion] = NSLocalizedString(@"BuyVM Manager (Stallion)", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionUsefulLinks][BVMAboutSettingsTableUsefulLinksRowClientArea] = NSLocalizedString(@"BuyVM Billing/Support", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionSettings][BVMAboutSettingsTableSettingsRowBrowser] = NSLocalizedString(@"Select Browser", nil);

        BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewSectionSupport] = BVMAboutSettingsTableSupportNumRows;
        BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewSectionUsefulLinks] = BVMAboutSettingsTableUsefulLinksNumRows;
        BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewSectionSettings] = BVMAboutSettingsTableSettingsNumRows;
    }
}

@interface BVMAboutSettingsViewController ()

@property (nonatomic, strong, readonly) UIView *footerView;
@property (nonatomic, weak, readonly) UILabel *footerLabel;

@end

@implementation BVMAboutSettingsViewController

@synthesize footerLabel = _footerLabel,
            footerView = _footerView,
            dismissBlock = _dismissBlock
            ;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"BuyVM Manager", nil);

    self.tableView.tableFooterView = self.footerView;

    self.tableView.backgroundColor = [UIColor bvm_tableViewBackgroundColor];
    self.tableView.backgroundView = nil;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneButtonTapped)];

    self.contentSizeForViewInPopover = CGSizeMake(320, self.footerView.frame.origin.y + self.footerView.frame.size.height);
}

#pragma mark Interface actions

- (void)reportIssue
{
    NSString *url = @"https://github.com/cdzombak/BuyVMManager-iOS/issues/new";
    [CDZLinkOpenManager openURLString:url];
}

- (void)openGithubProject
{
    NSString *url = @"https://github.com/cdzombak/BuyVMManager-iOS/";
    [CDZLinkOpenManager openURLString:url];
}

- (void)openStallion
{
    NSString *url = @"https://manage.buyvm.net";
    [CDZLinkOpenManager openURLString:url];
}

- (void)openClientArea
{
    NSString *url = @"https://my.frantech.ca";
    [CDZLinkOpenManager openURLString:url];
}

- (void)doneButtonTapped
{
    if (self.dismissBlock) self.dismissBlock();
    else NSLog(@"%@ cannot dismiss without a dismissBlock", NSStringFromClass([self class]));
}

- (void)pushToBrowserSelector
{
    UIViewController *browserSelector = [[CDZBrowserSelectorViewController alloc] init];
    [self.navigationController pushViewController:browserSelector animated:YES];
}

#pragma mark Helpers

+ (NSString *)appVersion
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return BVMAboutSettingsTableViewNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BVMAboutSettingsTableRowsInSection[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    cell.textLabel.text = BVMAboutSettingsTableRowTitles[indexPath.section][indexPath.row];

    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case BVMAboutSettingsTableViewSectionSupport:
            if (indexPath.row == BVMAboutSettingsTableSupportRowReportIssue) {
                [self reportIssue];
            } else if (indexPath.row == BVMAboutSettingsTableSupportRowGithubProject) {
                [self openGithubProject];
            }
            break;

        case BVMAboutSettingsTableViewSectionUsefulLinks:
            if (indexPath.row == BVMAboutSettingsTableUsefulLinksRowClientArea) {
                [self openClientArea];
            } else if (indexPath.row == BVMAboutSettingsTableUsefulLinksRowStallion) {
                [self openStallion];
            } else {
                NSLog(@"Unrecognized row %d in %s", indexPath.row, __PRETTY_FUNCTION__);
            }
            break;

        case BVMAboutSettingsTableViewSectionSettings:
            NSParameterAssert(indexPath.row == 0);
            [self pushToBrowserSelector];
            break;

        default:
            NSLog(@"Unrecognized section %d in %s", indexPath.section, __PRETTY_FUNCTION__);
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Property Overrides

- (UIView *)footerView
{
    if (!_footerView) {
        NSString *notes = [NSString stringWithFormat:NSLocalizedString(@"BuyVM Manager v%@", nil), [BVMAboutSettingsViewController appVersion]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.bounds.size.width-36, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.shadowColor = [UIColor bvm_darkGrayTextShadowColor];
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

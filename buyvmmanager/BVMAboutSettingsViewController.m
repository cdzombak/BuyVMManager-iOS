#import "BVMAboutSettingsViewController.h"
#import "BVMBrowserSelectorViewController.h"
#import "CDZLinkOpenManager.h"

typedef NS_ENUM(NSUInteger, BVMAboutSettingsTableViewSections) {
    BVMAboutSettingsTableViewSectionUsefulLinks = 0,
    BVMAboutSettingsTableViewSectionSupport,
    BVMAboutSettingsTableViewSectionSettings,
    BVMAboutSettingsTableViewNumSections
};

typedef NS_ENUM(NSUInteger, BVMAboutSettingsTableSupportRows) {
    BVMAboutSettingsTableSupportRowReportIssue = 0,
    BVMAboutSettingsTableSupportRowGithubProject,
    BVMAboutSettingsTableSupportRowLicense,
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

static NSString * BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewNumSections][3];
static NSInteger BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewNumSections];

__attribute__((constructor)) static void __BVMAboutSettingsViewControllerTableConstantsInit(void)
{
    @autoreleasepool {
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionSupport][BVMAboutSettingsTableSupportRowReportIssue] = NSLocalizedString(@"Report Issue", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionSupport][BVMAboutSettingsTableSupportRowGithubProject] = NSLocalizedString(@"Github Project", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionSupport][BVMAboutSettingsTableSupportRowLicense] = NSLocalizedString(@"License", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionUsefulLinks][BVMAboutSettingsTableUsefulLinksRowStallion] = NSLocalizedString(@"BuyVM Manager (Stallion)", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionUsefulLinks][BVMAboutSettingsTableUsefulLinksRowClientArea] = NSLocalizedString(@"BuyVM Billing/Support", nil);
        BVMAboutSettingsTableRowTitles[BVMAboutSettingsTableViewSectionSettings][BVMAboutSettingsTableSettingsRowBrowser] = NSLocalizedString(@"Select Browser", nil);

        BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewSectionSupport] = BVMAboutSettingsTableSupportNumRows;
        BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewSectionUsefulLinks] = BVMAboutSettingsTableUsefulLinksNumRows;
        BVMAboutSettingsTableRowsInSection[BVMAboutSettingsTableViewSectionSettings] = BVMAboutSettingsTableSettingsNumRows;
    }
}

@implementation BVMAboutSettingsViewController

@synthesize dismissBlock = _dismissBlock;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:NSLocalizedString(@"BuyVM Manager v%@", nil), [BVMAboutSettingsViewController appVersion]];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneButtonTapped)];
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

- (void)openLicense
{
    NSString *url = @"https://github.com/cdzombak/BuyVMManager-iOS/blob/master/LICENSE";
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
    UIViewController *browserSelector = [[BVMBrowserSelectorViewController alloc] init];
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
            } else if (indexPath.row == BVMAboutSettingsTableSupportRowLicense) {
                [self openLicense];
            } else {
                NSLog(@"Unrecognized row %d in %s", indexPath.row, __PRETTY_FUNCTION__);
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

@end

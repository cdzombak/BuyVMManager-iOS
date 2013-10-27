#import "BVMServerViewController.h"

#import "MBProgressHUD.h"
#import "CDZPinger.h"

#import "BVMServerInfo.h"
#import "BVMServerActionPerform.h"
#import "BVMHumanValueTransformer.h"
#import "BVMIPListViewController.h"
#import "BVMSizesListViewController.h"
#import "UIColor+BVMColors.h"


typedef NS_ENUM(NSUInteger, BVMServerTableViewSections) {
    BVMServerTableViewSectionHostname = 0,
    BVMServerTableViewSectionInfo,
    BVMServerTableViewSectionPing,
    BVMServerTableViewSectionAction,
    BVMServerTableViewNumSections
};

typedef NS_ENUM(NSUInteger, BVMServerTableViewInfoRows) {
    BVMServerTableViewInfoRowIP = 0,
    BVMServerTableViewInfoRowBandwidth,
    BVMServerTableViewInfoRowMemory,
    BVMServerTableViewInfoRowHDD,
    BVMServerTableViewInfoNumRows
};

typedef NS_ENUM(NSUInteger, BVMServerTableViewPingRows) {
    BVMServerTableViewPingRow = 0,
    BVMServerTableViewPingNumRows
};

typedef NS_ENUM(NSUInteger, BVMServerTableViewActionRows) {
    BVMServerTableViewActionRowReboot = 0,
    BVMServerTableViewActionRowBoot,
    BVMServerTableViewActionRowShutdown,
    BVMServerTableViewActionNumRows
};

static NSString * BVMServerTableViewActionStrings[BVMServerTableViewActionNumRows];
__attribute__((constructor)) static void __BVMServerTableViewConstantsInit(void)
{
    @autoreleasepool {
        BVMServerTableViewActionStrings[BVMServerTableViewActionRowReboot] = NSLocalizedString(@"Reboot", nil);
        BVMServerTableViewActionStrings[BVMServerTableViewActionRowBoot] = NSLocalizedString(@"Boot", nil);
        BVMServerTableViewActionStrings[BVMServerTableViewActionRowShutdown] = NSLocalizedString(@"Shutdown", nil);
    }
}

@interface BVMServerViewController () <CDZPingerDelegate>

@property (nonatomic, copy) NSString *serverId;
@property (nonatomic, copy) NSString *serverName;
@property (nonatomic, strong) BVMServerInfo *serverInfo;

@property (nonatomic, copy) NSString *pingString;
@property (nonatomic, strong) CDZPinger *pinger;

@property (nonatomic, assign) BVMServerAction selectedAction;

@property (nonatomic, strong) UIAlertView *actionAlertView;
@property (nonatomic, strong) UIAlertView *loadErrorAlertView;

@property (nonatomic, readonly) UIBarButtonItem *reloadButtonItem;

@property (nonatomic, readonly) MBProgressHUD *progressHUD;

@property (nonatomic, readonly) UITableViewCell *hostnameCell;

@end

@implementation BVMServerViewController

@synthesize reloadButtonItem = _reloadButtonItem,
            progressHUD = _progressHUD,
            hostnameCell = _hostnameCell
            ;

- (id)initWithServerId:(NSString *)serverId name:(NSString *)serverName
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.serverId = serverId;
        self.serverName = serverName;
        self.title = serverName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.reloadButtonItem;

    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    for (NSIndexPath *ip in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:ip animated:YES];
    }
}

#pragma mark BVM Data Management

- (void)reloadData
{
    // flow: reloadData reloads all data in the background, without erasing whatever is there now.
    //       anything that is available instantly tells the table view to refresh that row.
    //       async requests should tell the table view to refresh the appropriate row later.
    //       cellForRowAtIndexPath: adds appropriate data if available.

    [self.progressHUD show:YES];
    self.navigationItem.rightBarButtonItem = nil;

    [BVMServerInfo requestInfoForServerId:self.serverId withBlock:^(BVMServerInfo *info, NSError *error) {
        [self.progressHUD hide:YES];
        self.navigationItem.rightBarButtonItem = self.reloadButtonItem;

        if (error) {
            self.loadErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:[BVMHumanValueTransformer shortErrorFromError:error]
                                                            delegate:self
                                                   cancelButtonTitle:@":("
                                                   otherButtonTitles:nil];
            [self.loadErrorAlertView show];
            if (!self.serverInfo) self.hostnameCell.textLabel.text = @"";
            return;
        }
        self.serverInfo = info;

        if (self.serverInfo.status == BVMServerStatusOnline) {
            [self restartPing];
        } else {
            self.pingString = @"";
            self.pinger = nil;
        }

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[
            [NSIndexPath indexPathForRow:BVMServerTableViewInfoRowBandwidth inSection:BVMServerTableViewSectionInfo],
            [NSIndexPath indexPathForRow:BVMServerTableViewInfoRowHDD inSection:BVMServerTableViewSectionInfo],
            [NSIndexPath indexPathForRow:BVMServerTableViewInfoRowIP inSection:BVMServerTableViewSectionInfo],
            [NSIndexPath indexPathForRow:BVMServerTableViewInfoRowMemory inSection:BVMServerTableViewSectionInfo],
            [NSIndexPath indexPathForRow:BVMServerTableViewPingRow inSection:BVMServerTableViewSectionPing]
         ] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];

        [self refreshHostnameCell];
    }];
}

- (void)restartPing
{
    self.pingString = nil;
    self.pinger = nil;

    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:BVMServerTableViewSectionPing];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];

    [self.pinger startPinging];
}

- (void)refreshHostnameCell
{
    self.hostnameCell.textLabel.text = self.serverInfo.hostname;
    if (self.serverInfo.status == BVMServerStatusOnline) {
        self.hostnameCell.detailTextLabel.text = NSLocalizedString(@"Online", nil);
        self.hostnameCell.detailTextLabel.textColor = [UIColor bvm_onlineTextColor];
    } else {
        self.hostnameCell.detailTextLabel.text = NSLocalizedString(@"Offline", nil);
        self.hostnameCell.detailTextLabel.textColor = [UIColor redColor];
    }
}

#pragma mark CDZPingerDelegate methods

- (void)pinger:(CDZPinger *)pinger didUpdateWithAverageSeconds:(NSTimeInterval)seconds
{
    self.pingString = [NSString stringWithFormat:@"%.f ms", seconds*1000];

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:BVMServerTableViewSectionPing]]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)pinger:(CDZPinger *)pinger didEncounterError:(NSError *)error
{
    if (pinger != self.pinger) return;

    self.pinger = nil;
    self.pingString = [BVMHumanValueTransformer shortErrorFromError:error];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSParameterAssert(tableView == self.tableView);
    return BVMServerTableViewNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(tableView == self.tableView);
    switch(section) {
        case BVMServerTableViewSectionHostname:
            return 1;
        case BVMServerTableViewSectionInfo:
            return BVMServerTableViewInfoNumRows;
        case BVMServerTableViewSectionPing:
            return BVMServerTableViewPingNumRows;
        case BVMServerTableViewSectionAction:
            return BVMServerTableViewActionNumRows;
        default:
            NSLog(@"Unknown section %d in %s", section, __PRETTY_FUNCTION__);
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BVMServerTableViewSectionHostname) return self.hostnameCell;

    static NSString * CellIdentifiers[BVMServerTableViewNumSections] = {
        @"HostNameCell",
        @"UITableViewCellStyleValue2",
        @"UITableViewCellStyleValue2",
        @"UITableViewCellStyleDefault"
    };
    UITableViewCellStyle style = indexPath.section == BVMServerTableViewSectionAction ? UITableViewCellStyleDefault : UITableViewCellStyleValue2;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifiers[indexPath.section]];

    switch(indexPath.section) {
        case BVMServerTableViewSectionInfo:
            if (self.serverInfo && self.serverInfo.status == BVMServerStatusOnline) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }

            switch(indexPath.row) {
                case BVMServerTableViewInfoRowBandwidth:
                    cell.textLabel.text = NSLocalizedString(@"Bandwidth", nil);
                    if (!self.serverInfo) cell.detailTextLabel.text = nil;
                    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ used (%d%%)",
                                                      [NSByteCountFormatter stringFromByteCount:self.serverInfo.bwUsed countStyle:NSByteCountFormatterCountStyleBinary],
                                                      self.serverInfo.bwPercentUsed];
                    break;
                case BVMServerTableViewInfoRowHDD:
                    cell.textLabel.text = NSLocalizedString(@"HDD", nil);
                    if (self.serverInfo.status != BVMServerStatusOnline) cell.detailTextLabel.text = nil;
                    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ used (%d%%)",
                                                      [NSByteCountFormatter stringFromByteCount:self.serverInfo.hddUsed countStyle:NSByteCountFormatterCountStyleBinary],
                                                      self.serverInfo.hddPercentUsed];
                    break;
                case BVMServerTableViewInfoRowIP:
                    cell.textLabel.text = NSLocalizedString(@"IP", nil);
                    cell.detailTextLabel.text = self.serverInfo.mainIpAddress;
                    break;
                case BVMServerTableViewInfoRowMemory:
                    cell.textLabel.text = NSLocalizedString(@"Memory", nil);
                    if (self.serverInfo.status != BVMServerStatusOnline) cell.detailTextLabel.text = nil;
                    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ used (%d%%)",
                                                      [NSByteCountFormatter stringFromByteCount:self.serverInfo.memUsed countStyle:NSByteCountFormatterCountStyleBinary],
                                                      self.serverInfo.memPercentUsed];
                    break;
            }
            break;
        case BVMServerTableViewSectionPing:
            NSParameterAssert(indexPath.row == 0);
            cell.textLabel.text = NSLocalizedString(@"Ping", nil);
            if (self.pingString) {
                cell.detailTextLabel.text = self.pingString;
            }
            else {
                cell.detailTextLabel.text = nil;
                if (self.serverInfo) {
                    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [indicator startAnimating];
                    CGRect indicatorFrame = indicator.frame;
                    indicatorFrame.origin.x = 85;
                    indicatorFrame.origin.y = cell.bounds.size.height/2 - indicator.bounds.size.height/2 - 1;
                    indicator.frame = indicatorFrame;
                    [cell.contentView addSubview:indicator];
                }
            }
            break;
        case BVMServerTableViewSectionAction:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = BVMServerTableViewActionStrings[indexPath.row];
            cell.textLabel.textColor = [UIColor darkTextColor];
            break;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BVMServerTableViewSectionInfo) {
        UIViewController *vc = nil;
        switch (indexPath.row) {
            case BVMServerTableViewInfoRowIP: {
                vc = [[BVMIPListViewController alloc] initWithServer:self.serverName
                                                                 ips:self.serverInfo.ipAddresses];
                break;
            }
            case BVMServerTableViewInfoRowBandwidth: {
                vc = [[BVMSizesListViewController alloc] initWithServer:self.serverName
                                                              statistic:NSLocalizedString(@"Bandwidth", nil)
                                                                  total:self.serverInfo.bwTotal
                                                                   used:self.serverInfo.bwUsed
                                                                   free:self.serverInfo.bwFree
                                                            percentUsed:self.serverInfo.bwPercentUsed];
                break;
            }
            case BVMServerTableViewInfoRowHDD: {
                vc = [[BVMSizesListViewController alloc] initWithServer:self.serverName
                                                              statistic:NSLocalizedString(@"HDD", nil)
                                                                  total:self.serverInfo.hddTotal
                                                                   used:self.serverInfo.hddUsed
                                                                   free:self.serverInfo.hddFree
                                                            percentUsed:self.serverInfo.hddPercentUsed];
                break;
            }
            case BVMServerTableViewInfoRowMemory: {
                vc = [[BVMSizesListViewController alloc] initWithServer:self.serverName
                                                              statistic:NSLocalizedString(@"Memory", nil)
                                                                  total:self.serverInfo.memTotal
                                                                   used:self.serverInfo.memUsed
                                                                   free:self.serverInfo.memFree
                                                            percentUsed:self.serverInfo.memPercentUsed];
                break;
            }
        }
        if (vc) [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == BVMServerTableViewSectionAction) {
        switch (indexPath.row) {
            case BVMServerTableViewActionRowBoot:
                self.selectedAction = BVMServerActionBoot;
                break;
            case BVMServerTableViewActionRowReboot:
                self.selectedAction = BVMServerActionReboot;
                break;
            case BVMServerTableViewActionRowShutdown:
                self.selectedAction = BVMServerActionShutdown;
                break;
        }
        [self displayActionAlertView];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (indexPath.section == BVMServerTableViewSectionPing) {
        NSParameterAssert(indexPath.row == 0);
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self restartPing];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.serverInfo || self.serverInfo.status != BVMServerStatusOnline) {
        if (indexPath.section == BVMServerTableViewSectionInfo
            || indexPath.section == BVMServerTableViewSectionPing) {
            return nil;
        }
    }

    if (indexPath.section == BVMServerTableViewSectionHostname) return nil;

    return indexPath;
}

#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.actionAlertView) {
        NSString *hostname = [[alertView textFieldAtIndex:0] text];
        [self actionAlertViewDidDismissWithButtonIndex:buttonIndex enteredHostname:hostname];
    }

    if (alertView == self.loadErrorAlertView) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark Server Actions

- (void)displayActionAlertView
{
    NSString *message;
    switch (self.selectedAction) {
        case BVMServerActionBoot:
            message = NSLocalizedString(@"You are attempting to boot a VM.\nEnter the hostname to confirm:", nil);
            break;
        case BVMServerActionReboot:
            message = NSLocalizedString(@"Attempting to REBOOT a VM.\nEnter the hostname to confirm:", nil);
            break;
        case BVMServerActionShutdown:
            message = NSLocalizedString(@"Attempting to SHUT DOWN a VM.\nEnter the hostname to confirm:", nil);
            break;
    }

    self.actionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", nil)
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                            otherButtonTitles:@"OK", nil];
    self.actionAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.actionAlertView show];
}

- (void)actionAlertViewDidDismissWithButtonIndex:(NSInteger)buttonIndex enteredHostname:(NSString *)hostname
{
    static NSInteger cancelButtonIndex = 0;

    if (buttonIndex == cancelButtonIndex) return;

    if ([[hostname lowercaseString] isEqualToString:[self.serverInfo.hostname lowercaseString]]) {
        [BVMServerActionPerform performAction:self.selectedAction forServerId:self.serverId withBlock:^(BVMServerActionStatus status, NSError *error) {
            if (error || status == BVMServerActionStatusIndeterminate) {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:[BVMHumanValueTransformer shortErrorFromError:error]
                                           delegate:nil
                                  cancelButtonTitle:@":("
                                  otherButtonTitles:nil]
                 show];
            } else {
                [self reportServerActionStatus:status];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:NSLocalizedString(@"The hostname entered was incorrect.", nil)
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
}

- (void)reportServerActionStatus:(BVMServerActionStatus)status
{
    switch (status) {
        case BVMServerActionStatusBooted:
            self.hostnameCell.detailTextLabel.text = NSLocalizedString(@"Booting...", nil);
            break;
        case BVMServerActionStatusRebooted:
            self.hostnameCell.detailTextLabel.text = NSLocalizedString(@"Rebooting...", nil);
            break;
        case BVMServerActionStatusShutdown:
            self.hostnameCell.detailTextLabel.text = NSLocalizedString(@"Shutting down...", nil);
            break;
        default: break;
    }

    self.hostnameCell.detailTextLabel.textColor = [UIColor blackColor];
    self.pinger = nil;
    self.pingString = @"";
    self.serverInfo.status = BVMServerStatusIndeterminate;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
    [self.progressHUD show:YES];

    [self performSelector:@selector(reloadData) withObject:nil afterDelay:6.0];
}

#pragma mark Pasteboard Copying

-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
    }
}

-(BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
    if (indexPath.section == BVMServerTableViewSectionInfo || indexPath.section == BVMServerTableViewSectionPing) {
        if (action == @selector(copy:)) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == BVMServerTableViewSectionInfo || indexPath.section == BVMServerTableViewSectionPing) {
        return YES;
    }
    return NO;
}

#pragma mark Property overrides

- (CDZPinger *)pinger
{
    if (!_pinger) {
        _pinger = [[CDZPinger alloc] initWithHost:self.serverInfo.mainIpAddress];
        _pinger.delegate = self;
    }
    return _pinger;
}

- (UIBarButtonItem *)reloadButtonItem
{
    if (!_reloadButtonItem) {
        _reloadButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData)];
    }
    return _reloadButtonItem;
}

- (MBProgressHUD *)progressHUD
{
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (UITableViewCell *)hostnameCell {
    if (!_hostnameCell) {
        _hostnameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"HostNameCell"];
        _hostnameCell.detailTextLabel.font = [UIFont boldSystemFontOfSize:_hostnameCell.detailTextLabel.font.pointSize];
        _hostnameCell.textLabel.textColor = [UIColor blackColor];

    }
    return _hostnameCell;
}

@end

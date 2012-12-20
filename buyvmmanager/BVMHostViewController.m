#import "BVMHostViewController.h"
#import "BVMServerInfo.h"
#import "BVMPinger.h"
#import "BVMHumanValueTransformer.h"

typedef NS_ENUM(NSUInteger, BVMHostTableViewSections) {
    BVMHostTableViewSectionInfo = 0,
    BVMHostTableViewSectionPing,
    BVMHostTableViewSectionAction,
    BVMHostTableViewNumSections
};

typedef NS_ENUM(NSUInteger, BVMHostTableViewInfoRows) {
    BVMHostTableViewInfoRowIP = 0,
    BVMHostTableViewInfoRowBandwidth,
    BVMHostTableViewInfoRowMemory,
    BVMHostTableViewInfoRowHDD,
    BVMHostTableViewInfoNumRows
};

typedef NS_ENUM(NSUInteger, BVMHostTableViewPingRows) {
    BVMHostTableViewPingRow = 0,
    BVMHostTableViewPingNumRows
};

typedef NS_ENUM(NSUInteger, BVMHostTableViewActionRows) {
    BVMHostTableViewActionRowReboot = 0,
    BVMHostTableViewActionRowBoot,
    BVMHostTableViewActionRowShutdown,
    BVMHostTableViewActionNumRows
};

static NSString * BVMHostTableViewActionStrings[BVMHostTableViewActionNumRows];
__attribute__((constructor)) static void __BVMHostTableViewConstantsInit(void)
{
    @autoreleasepool {
        BVMHostTableViewActionStrings[BVMHostTableViewActionRowReboot] = NSLocalizedString(@"Reboot", nil);
        BVMHostTableViewActionStrings[BVMHostTableViewActionRowBoot] = NSLocalizedString(@"Boot", nil);
        BVMHostTableViewActionStrings[BVMHostTableViewActionRowShutdown] = NSLocalizedString(@"Shutdown", nil);
    }
}

@interface BVMHostViewController () <BVMPingerTimingDelegate>

@property (nonatomic, copy) NSString *serverName;
@property (nonatomic, strong) BVMServerInfo *serverInfo;
@property (nonatomic, copy) NSString *pingString;
@property (nonatomic, strong) BVMPinger *pinger;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *headerHostnameLabel;
@property (nonatomic, strong) UILabel *headerStatusLabel;

@end

@implementation BVMHostViewController

- (id)initWithServer:(NSString *)serverName
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.serverName = serverName;
        self.title = serverName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableHeaderView = self.headerView;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(reloadData)];

    [self reloadData];
}

#pragma mark BVM Data Management

- (void)reloadData
{
    // flow: reloadData reloads all data in the background, without erasing whatever is there now.
    //       anything that is available instantly tells the table view to refresh that row.
    //       async requests should tell the table view to refresh the appropriate row later.
    //       cellForRowAtIndexPath: adds appropriate data if available.

    [BVMServerInfo requestInfoForServer:self.serverName withBlock:^(BVMServerInfo *info, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@":("
                              otherButtonTitles:nil]
             show];
            return;
        }
        self.serverInfo = info;

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[
            [NSIndexPath indexPathForRow:BVMHostTableViewInfoRowBandwidth inSection:BVMHostTableViewSectionInfo],
            [NSIndexPath indexPathForRow:BVMHostTableViewInfoRowHDD inSection:BVMHostTableViewSectionInfo],
            [NSIndexPath indexPathForRow:BVMHostTableViewInfoRowIP inSection:BVMHostTableViewSectionInfo],
            [NSIndexPath indexPathForRow:BVMHostTableViewInfoRowMemory inSection:BVMHostTableViewSectionInfo],
         ] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];

        [self refreshHeaderView];

        self.pinger = [[BVMPinger alloc] initWithHost:self.serverInfo.mainIpAddress];
        self.pinger.timingDelegate = self;
        [self.pinger startPinging];
    }];

    if (self.pinger) {
        [self.pinger stopPinging];
        self.pinger = nil;
    }
}

- (void)refreshHeaderView
{
    self.headerHostnameLabel.text = self.serverInfo.hostname;
    if (self.serverInfo.status == BVMServerStatusOnline) {
        self.headerStatusLabel.text = NSLocalizedString(@"Online", nil);
        self.headerStatusLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:136.0/255.0 blue:80.0/255.0 alpha:1.0];
    } else {
        self.headerStatusLabel.text = NSLocalizedString(@"Offline", nil);
        self.headerStatusLabel.textColor = [UIColor redColor];
    }
}

#pragma mark BVMPingerTimingDelegate methods

- (void)pinger:(BVMPinger *)pinger didUpdateWithTime :(double)seconds
{
    self.pingString = [NSString stringWithFormat:@"%.f ms", rint(seconds*1000)];

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:BVMHostTableViewSectionPing]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSParameterAssert(tableView == self.tableView);
    return BVMHostTableViewNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(tableView == self.tableView);
    switch(section) {
        case BVMHostTableViewSectionInfo:
            return BVMHostTableViewInfoNumRows;
        case BVMHostTableViewSectionPing:
            return BVMHostTableViewPingNumRows;
        case BVMHostTableViewSectionAction:
            return BVMHostTableViewActionNumRows;
        default:
            NSLog(@"Unknown section %d in %s", section, __PRETTY_FUNCTION__);
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifiers[BVMHostTableViewNumSections] = {
        @"UITableViewCellStyleValue2",
        @"UITableViewCellStyleValue2",
        @"UITableViewCellStyleDefault"
    };
    UITableViewCellStyle style = indexPath.section == BVMHostTableViewSectionAction ? UITableViewCellStyleDefault : UITableViewCellStyleValue2;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifiers[indexPath.section]];
    
    switch(indexPath.section) {
        case BVMHostTableViewSectionInfo:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch(indexPath.row) {
                case BVMHostTableViewInfoRowBandwidth:
                    cell.textLabel.text = NSLocalizedString(@"Bandwidth", nil);
                    if (self.serverInfo.bwTotal == 0) cell.detailTextLabel.text = nil;
                    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ used (%d%%)",
                                                      [BVMHumanValueTransformer humanSizeValueFromBytes:self.serverInfo.bwUsed],
                                                      self.serverInfo.bwPercentUsed];
                    break;
                case BVMHostTableViewInfoRowHDD:
                    cell.textLabel.text = NSLocalizedString(@"HDD", nil);
                    if (self.serverInfo.hddTotal == 0) cell.detailTextLabel.text = nil;
                    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ used (%d%%)",
                                                      [BVMHumanValueTransformer humanSizeValueFromBytes:self.serverInfo.hddUsed],
                                                      self.serverInfo.hddPercentUsed];
                    break;
                case BVMHostTableViewInfoRowIP:
                    cell.textLabel.text = NSLocalizedString(@"IP", nil);
                    cell.detailTextLabel.text = self.serverInfo.mainIpAddress;
                    break;
                case BVMHostTableViewInfoRowMemory:
                    cell.textLabel.text = NSLocalizedString(@"Memory", nil);
                    if (self.serverInfo.memTotal == 0) cell.detailTextLabel.text = nil;
                    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ used (%d%%)",
                                                      [BVMHumanValueTransformer humanSizeValueFromBytes:self.serverInfo.memUsed],
                                                      self.serverInfo.memPercentUsed];
                    break;
            }
            break;
        case BVMHostTableViewSectionPing:
            NSParameterAssert(indexPath.row == 0);
            cell.textLabel.text = NSLocalizedString(@"Ping", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (self.pingString) {
                cell.detailTextLabel.text = self.pingString;
            }
            else {
                cell.detailTextLabel.text = nil;
                UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [indicator startAnimating];
                CGRect indicatorFrame = indicator.frame;
                indicatorFrame.origin.x = 85;
                indicatorFrame.origin.y = cell.bounds.size.height/2 - indicator.bounds.size.height/2;
                indicator.frame = indicatorFrame;
                [cell.contentView addSubview:indicator];
            }
            break;
        case BVMHostTableViewSectionAction:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = BVMHostTableViewActionStrings[indexPath.row];
            break;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(tableView == self.tableView);
    if (indexPath.section == BVMHostTableViewSectionPing) return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark Property overrides

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, { self.view.bounds.size.width, 65 } }];
        _headerView.autoresizesSubviews = YES;
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _headerView.backgroundColor = [UIColor clearColor];

        self.headerHostnameLabel = [[UILabel alloc] initWithFrame:(CGRect){ {25, 10} , { _headerView.bounds.size.width-50, 35 }}];
        self.headerHostnameLabel.font = [UIFont boldSystemFontOfSize:22.0];
        self.headerHostnameLabel.backgroundColor = [UIColor clearColor];
        self.headerHostnameLabel.text = @"...";
        self.headerHostnameLabel.shadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.headerHostnameLabel.shadowOffset = CGSizeMake(0, -2.0);
        [_headerView addSubview:self.headerHostnameLabel];

        self.headerStatusLabel = [[UILabel alloc] initWithFrame:(CGRect){ {25, 41} , { _headerView.bounds.size.width-50, 20 }}];
        self.headerStatusLabel.font = [UIFont boldSystemFontOfSize:18.0];
        self.headerStatusLabel.backgroundColor = [UIColor clearColor];
        self.headerStatusLabel.text = @"...";
        self.headerStatusLabel.shadowColor = self.headerHostnameLabel.shadowColor;
        self.headerStatusLabel.shadowOffset = self.headerHostnameLabel.shadowOffset;
        [_headerView addSubview:self.headerStatusLabel];
    }
    return _headerView;
}

@end

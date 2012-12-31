#import "BVMServersListViewController.h"
#import "BVMServersManager.h"
#import "BVMServerInfo.h"
#import "BVMAddEditServerViewController.h"
#import "BVMHostViewController.h"
#import "BVMAboutSettingsViewController.h"
#import "NSError+BVMErrors.h"
#import "UIColor+BVMColors.h"
#import "ODRefreshControl.h"

@interface BVMServersListViewController ()

@property (nonatomic, copy) NSDictionary *servers;
@property (nonatomic, strong) NSArray *orderedServerIds;

@property (nonatomic, weak) UINavigationController *detailNavigationVC;

@property (nonatomic, strong, readonly) UIBarButtonItem *addItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *settingsItem;

@property (nonatomic, strong) ODRefreshControl *thirdPartyRefreshControl;

@property (nonatomic, assign) BOOL showedFirstLaunchAddScreen;

@property (nonatomic, strong, readonly) BVMAddEditServerViewController *addVC;
@property (nonatomic, strong, readonly) UIPopoverController *addVCPopoverController;

@property (nonatomic, strong, readonly) BVMAboutSettingsViewController *settingsVC;
@property (nonatomic, strong, readonly) UIPopoverController *settingsVCPopoverController;

@property (nonatomic, strong) UIPopoverController *currentEditingPopoverController;

@property (nonatomic, strong, readonly) UIToolbar *bottomToolbar;

@end

@implementation BVMServersListViewController

@synthesize addItem = _addItem,
            settingsItem = _settingsItem,
            addVC = _addVC,
            addVCPopoverController = _addVCPopoverController,
            settingsVC = _settingsVC,
            settingsVCPopoverController = _settingsVCPopoverController,
            bottomToolbar = _bottomToolbar
            ;

- (id)initWithDetailNavigationController:(UINavigationController *)navigationController
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.detailNavigationVC = navigationController;
        self.showedFirstLaunchAddScreen = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"My VMs", nil);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.thirdPartyRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    self.thirdPartyRefreshControl.backgroundColor = [UIColor bvm_pullRefreshBackgroundColor];
    [self.thirdPartyRefreshControl addTarget:self action:@selector(refreshControlActivated:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:self.bottomToolbar];
    self.view.autoresizesSubviews = YES;

    self.tableView.allowsSelectionDuringEditing = YES;

    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    static const CGFloat ToolbarHeight = 44.0; // le sigh
    self.bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height - ToolbarHeight,
                                          self.view.bounds.size.width, ToolbarHeight);
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.servers.count == 0 && !self.showedFirstLaunchAddScreen) {
        self.showedFirstLaunchAddScreen = YES;
        self.editing = YES;
        [self addButtonTouched];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing) {
        self.navigationItem.leftBarButtonItem = self.addItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)addButtonTouched
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.addVCPopoverController presentPopoverFromBarButtonItem:self.addItem
                                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                animated:YES];
    } else {
        UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:self.addVC];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)settingsButtonTouched
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.settingsVCPopoverController presentPopoverFromBarButtonItem:self.settingsItem
                                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                 animated:YES];
    } else {
        UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:self.settingsVC];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)refreshControlActivated:(id)sender
{
    [self reloadData];

    [self.thirdPartyRefreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.2];
}

- (void)displayEditorForIndexPath:(NSIndexPath *)indexPath
{
    NSString *serverId = [self serverIdForIndexPath:indexPath];
    UIView *presentingCell = [self.tableView cellForRowAtIndexPath:indexPath];

    BVMAddEditServerViewController *editVc = [[BVMAddEditServerViewController alloc] initForServerId:serverId];
    editVc.afterAddTarget = self;
    editVc.afterAddAction = @selector(reloadData);
    UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:editVc];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.currentEditingPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        editVc.myPopoverController = self.currentEditingPopoverController;
        [self.currentEditingPopoverController presentPopoverFromRect:presentingCell.frame
                                                              inView:self.tableView
                                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                                            animated:YES];
    } else {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark Data

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSString *serverId = [self serverIdForIndexPath:indexPath];
    NSString *serverName = [self serverNameForIndexPath:indexPath];

    cell.textLabel.text = serverName;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = @"";

    [BVMServerInfo requestStatusForServerId:serverId
                                  withBlock:^(BVMServerStatus status, NSString *hostname, NSString *ip, NSError *error) {
                                      if (status == BVMServerStatusOffline) {
                                          cell.textLabel.textColor = [UIColor redColor];
                                          cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ [offline]", nil), cell.textLabel.text];
                                      } else if (status == BVMServerStatusIndeterminate) {
                                          cell.textLabel.textColor = [UIColor blueColor];
                                          cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ [unknown]", nil), cell.textLabel.text];
                                      }
                                      if (ip && hostname) {
                                          cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", ip, hostname];
                                      } else if (ip) {
                                          cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", ip];
                                      } else if (hostname) {
                                          cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@)", hostname];
                                      }
                                      [cell setNeedsLayout];
                                  }];
}

- (void)reloadData
{
    self.servers = [BVMServersManager servers];

    [self.tableView reloadData];
}

- (NSString *)serverIdForIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath.section == 0);
    return self.orderedServerIds[indexPath.row];
}

- (NSString *)serverNameForIndexPath:(NSIndexPath *)indexPath
{
    NSString *serverId = [self serverIdForIndexPath:indexPath];
    return self.servers[serverId];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *serverId = [self serverIdForIndexPath:indexPath];
        [BVMServersManager removeServerId:serverId];
        self.servers = [BVMServersManager servers];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *serverId = [self serverIdForIndexPath:indexPath];
    NSString *serverName = [self serverNameForIndexPath:indexPath];

    if (tableView.editing) {
        [self displayEditorForIndexPath:indexPath];
        return;
    }

    UIViewController *hostVC = [[BVMHostViewController alloc] initWithServerId:serverId name:serverName];

    if (!self.detailNavigationVC || self.detailNavigationVC == self.navigationController) {
        [self.navigationController pushViewController:hostVC animated:YES];
    } else {
        [self.detailNavigationVC setViewControllers:@[hostVC] animated:NO];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark Property Overrides

- (void)setServers:(NSDictionary *)servers
{
    _servers = [servers copy];
    self.orderedServerIds = [_servers keysSortedByValueUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UIBarButtonItem *)addItem
{
    if (!_addItem) {
        _addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouched)];
    }
    return _addItem;
}

- (UIBarButtonItem *)settingsItem
{
    if (!_settingsItem) {
        _settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"247-InfoCircle"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTouched)];
    }
    return _settingsItem;
}

- (UIPopoverController *)addVCPopoverController
{
    if (!_addVCPopoverController) {
        UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:self.addVC];
        _addVCPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        _addVC.myPopoverController = _addVCPopoverController;
    }
    return _addVCPopoverController;
}

- (BVMAddEditServerViewController *)addVC
{
    if (!_addVC) {
        _addVC = [[BVMAddEditServerViewController alloc] initForServerId:nil];
        _addVC.afterAddTarget = self;
        _addVC.afterAddAction = @selector(reloadData);
    }
    return _addVC;
}

- (UIPopoverController *)settingsVCPopoverController
{
    if (!_settingsVCPopoverController) {
        _settingsVCPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.settingsVC];
    }
    return _settingsVCPopoverController;
}

- (BVMAboutSettingsViewController *)settingsVC
{
    if (!_settingsVC) {
        _settingsVC = [[BVMAboutSettingsViewController alloc] init];
    }
    return _settingsVC;
}

- (UIToolbar *)bottomToolbar
{
    if (!_bottomToolbar) {
        _bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        _bottomToolbar.items = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            self.settingsItem
        ];
        _bottomToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    return _bottomToolbar;
}

@end

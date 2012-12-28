#import "BVMServersListViewController.h"
#import "BVMServersManager.h"
#import "BVMServerInfo.h"
#import "BVMAddServerViewController.h"
#import "BVMHostViewController.h"
#import "BVMAboutSettingsViewController.h"
#import "NSError+BVMErrors.h"
#import "ODRefreshControl.h"

@interface BVMServersListViewController ()

@property (nonatomic, strong) NSArray *serverNames;

@property (nonatomic, strong, readonly) UIBarButtonItem *addItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *settingsItem;

@property (nonatomic, strong) ODRefreshControl *thirdPartyRefreshControl;

@property (nonatomic, strong, readonly) BVMAddServerViewController *addVC;
@property (nonatomic, strong, readonly) UIPopoverController *addVCPopoverController;

@end

@implementation BVMServersListViewController

@synthesize addItem = _addItem,
            settingsItem = _settingsItem,
            addVC = _addVC,
            addVCPopoverController = _addVCPopoverController
            ;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.serverNames = [BVMServersManager serverNames];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"My VMs", nil);
    self.navigationItem.leftBarButtonItem = self.settingsItem;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.thirdPartyRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    self.thirdPartyRefreshControl.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.thirdPartyRefreshControl addTarget:self action:@selector(refreshControlActivated:) forControlEvents:UIControlEventValueChanged];

    if (self.serverNames.count == 0) {
        // TODO clean presentation on first launch
//        [self addButtonTouched];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing) {
        self.navigationItem.leftBarButtonItem = self.addItem;
    } else {
        self.navigationItem.leftBarButtonItem = self.settingsItem;
    }
}

- (void)addButtonTouched
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.addVCPopoverController presentPopoverFromBarButtonItem:self.addItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:self.addVC];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)settingsButtonTouched
{
    BVMAboutSettingsViewController *settingsVc = [[BVMAboutSettingsViewController alloc] init];
    UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:settingsVc];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)refreshControlActivated:(id)sender
{
    [self.tableView reloadData];

    [self.thirdPartyRefreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.2];
}

#pragma mark Data

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSString *serverName = self.serverNames[indexPath.row];
    cell.textLabel.text = serverName;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = @"";
    [BVMServerInfo requestStatusForServer:serverName
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
    self.serverNames = [BVMServersManager serverNames];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.serverNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        [BVMServersManager removeServerNamed:self.serverNames[indexPath.row]];
        self.serverNames = [BVMServersManager serverNames];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = [[BVMHostViewController alloc] initWithServer:self.serverNames[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark Property Overrides

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

- (BVMAddServerViewController *)addVC
{
    if (!_addVC) {
        _addVC = [[BVMAddServerViewController alloc] init];
        _addVC.afterAddTarget = self;
        _addVC.afterAddAction = @selector(reloadData);
    }
    return _addVC;
}

@end

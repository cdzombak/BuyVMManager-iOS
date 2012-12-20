#import "BVMServersListViewController.h"
#import "BVMServersManager.h"
#import "BVMServerInfo.h"
#import "BVMAddServerViewController.h"
#import "BVMHostViewController.h"

@interface BVMServersListViewController ()

@property (nonatomic, strong) NSArray *serverNames;

@property (nonatomic, strong, readonly) UIBarButtonItem *addItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *settingsItem;

@end

@implementation BVMServersListViewController

@synthesize addItem = _addItem,
            settingsItem = _settingsItem
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    BVMAddServerViewController *addVc = [[BVMAddServerViewController alloc] init];
    addVc.afterAddTarget = self;
    addVc.afterAddAction = @selector(reloadData);

    UIViewController *vc = [[UINavigationController alloc] initWithRootViewController:addVc];
    [self presentViewController:vc animated:YES completion:nil];
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
                                    }
                                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", ip, hostname];
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

@end

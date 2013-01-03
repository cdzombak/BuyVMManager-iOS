#import "BVMSizesListViewController.h"
#import "BVMHumanValueTransformer.h"
#import "UIColor+BVMColors.h"

@interface BVMSizesListViewController ()

@property (nonatomic, copy) NSString *statisticName;
@property (nonatomic, assign) long long totalBytes;
@property (nonatomic, assign) long long usedBytes;
@property (nonatomic, assign) long long freeBytes;
@property (nonatomic, assign) NSUInteger percentUsed;

@end

@implementation BVMSizesListViewController

- (id)initWithServer:(NSString *)serverName
           statistic:(NSString *)statisticName
               total:(long long)totalBytes
                used:(long long)usedBytes
                free:(long long)freeBytes
         percentUsed:(NSUInteger)percentUsed
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.statisticName = statisticName;
        self.totalBytes = totalBytes;
        self.usedBytes = usedBytes;
        self.freeBytes = freeBytes;
        self.percentUsed = percentUsed;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.allowsSelection = NO;
    
    self.tableView.backgroundColor = [UIColor bvm_tableViewBackgroundColor];
    self.tableView.backgroundView = nil;
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"CellIdentifier"];

    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Total", nil);
            cell.detailTextLabel.text = [BVMHumanValueTransformer humanSizeValueFromBytes:self.totalBytes];
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Used", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%d%%)",
                                         [BVMHumanValueTransformer humanSizeValueFromBytes:self.usedBytes],
                                         self.percentUsed];
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Free", nil);
            cell.detailTextLabel.text = [BVMHumanValueTransformer humanSizeValueFromBytes:self.freeBytes];
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.statisticName;
}

#pragma mark UITableViewDelegate methods

// stolen/hacked from http://stackoverflow.com/a/3574501
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 22.0)];
    customView.backgroundColor = [UIColor clearColor];

    CGFloat startX;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        startX = 38.0;
    } else {
        startX = 16.0;
    }

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    headerLabel.font = [UIFont boldSystemFontOfSize:18.0];
    headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    headerLabel.shadowColor = [UIColor bvm_darkGrayTextShadowColor];
    headerLabel.frame = CGRectMake(startX, 6.0, customView.bounds.size.width, 18.0);
    headerLabel.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    
    [customView addSubview:headerLabel];
    return customView;
}

@end

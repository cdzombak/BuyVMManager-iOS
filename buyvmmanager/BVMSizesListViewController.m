#import "BVMSizesListViewController.h"
#import "BVMHumanValueTransformer.h"

@interface BVMSizesListViewController ()

@property (nonatomic, copy) NSString *statisticName;
@property (nonatomic, assign) NSUInteger totalBytes;
@property (nonatomic, assign) NSUInteger usedBytes;
@property (nonatomic, assign) NSUInteger freeBytes;
@property (nonatomic, assign) NSUInteger percentUsed;

@end

@implementation BVMSizesListViewController

- (id)initWithServer:(NSString *)serverName
           statistic:(NSString *)statisticName
               total:(NSUInteger)totalBytes
                used:(NSUInteger)usedBytes
                free:(NSUInteger)freeBytes
         percentUsed:(NSUInteger)percentUsed
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = serverName;
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

// n/a

@end

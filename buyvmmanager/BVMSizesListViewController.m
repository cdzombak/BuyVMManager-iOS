#import "BVMSizesListViewController.h"
#import "BVMHumanValueTransformer.h"
#import "UIColor+BVMColors.h"

@interface BVMSizesListViewController ()

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
        self.title = statisticName;
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

    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Total", nil);
            cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:self.totalBytes countStyle:NSByteCountFormatterCountStyleBinary];
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Used", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%d%%)",
                                         [NSByteCountFormatter stringFromByteCount:self.usedBytes countStyle:NSByteCountFormatterCountStyleBinary],
                                         self.percentUsed];
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Free", nil);
            cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:self.freeBytes countStyle:NSByteCountFormatterCountStyleBinary];
            break;
    }
    
    return cell;
}

@end

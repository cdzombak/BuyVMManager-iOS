#import "BVMBrowserSelectorViewController.h"
#import "BVMLinkOpenManager.h"
#import "UIColor+BVMColors.h"

@interface BVMBrowserSelectorViewController ()

@property (nonatomic, strong) NSIndexPath *previouslySelectedIndexPath;

@end

@implementation BVMBrowserSelectorViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Select Browser", nil);

    self.tableView.backgroundColor = [UIColor bvm_tableViewBackgroundColor];
    self.tableView.backgroundView = nil;

    self.contentSizeForViewInPopover = CGSizeMake(320, 44*BVMNumBrowsers + 20);
}

#pragma mark UI Help

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [BVMLinkOpenManager nameForBrowser:indexPath.row];

    if ([BVMLinkOpenManager browserAvailable:indexPath.row]) {
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if ([BVMLinkOpenManager selectedBrowser] == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BVMNumBrowsers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [BVMLinkOpenManager setSelectedBrowser:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

    if (self.previouslySelectedIndexPath && [indexPath compare:self.previouslySelectedIndexPath] != NSOrderedSame) {
        [self.tableView cellForRowAtIndexPath:self.previouslySelectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // hack:
    self.previouslySelectedIndexPath = [NSIndexPath indexPathForRow:[BVMLinkOpenManager selectedBrowser] inSection:0];

    if ([BVMLinkOpenManager browserAvailable:indexPath.row]) return indexPath;
    else return nil;
}

@end

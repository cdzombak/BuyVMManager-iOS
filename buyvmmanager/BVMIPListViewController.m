#import "BVMIPListViewController.h"

@interface BVMIPListViewController ()

@property (nonatomic, strong) NSArray *ips;

@end

@implementation BVMIPListViewController

- (id)initWithServer:(NSString *)serverName ips:(NSArray *)ips
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.ips = ips;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.allowsSelection = NO;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger) self.ips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.ips[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

#pragma mark UITableViewDelegate

// n/a

#pragma mark Pasteboard Copying

-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.ips[indexPath.row];
    }
}

-(BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

@end

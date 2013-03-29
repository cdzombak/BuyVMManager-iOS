#import "BVMBrowserSelectorViewController.h"
#import "UIColor+BVMColors.h"

@interface BVMBrowserSelectorViewController ()

@end

@implementation BVMBrowserSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Select Browser", nil);

    self.tableView.backgroundColor = [UIColor bvm_tableViewBackgroundColor];
    self.tableView.backgroundView = nil;
    
    self.tableViewCellSelectionStyle = UITableViewCellSelectionStyleGray;

    CDZWeakSelf weakSelf = self;
    self.browserSelectedBlock = ^(CDZBrowser browser) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}

@end

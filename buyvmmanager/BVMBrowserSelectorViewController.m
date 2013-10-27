#import "BVMBrowserSelectorViewController.h"

@interface BVMBrowserSelectorViewController ()

@end

@implementation BVMBrowserSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Select Browser", nil);

    CDZWeakSelf weakSelf = self;
    self.browserSelectedBlock = ^(CDZBrowser browser) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}

@end

#import "BVMAppDelegate.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "BVMServersListViewController.h"

@implementation BVMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    id rootVC = [[UINavigationController alloc] initWithRootViewController:[[BVMServersListViewController alloc] init]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UISplitViewController *vc = [[UISplitViewController alloc] init];
        vc.delegate = self;
        vc.viewControllers = @[
            [[UINavigationController alloc] initWithRootViewController:[[BVMServersListViewController alloc] init]],
            [[UINavigationController alloc] initWithRootViewController:[[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped]]
        ];
        rootVC = vc;
    }

    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    return YES;
}

#pragma mark UISplitViewControllerDelegate methods

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    // nope, just keep both VCs visible always.
    return NO;
}

@end

#import "BVMAppDelegate.h"
#import "UIColor+BVMColors.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "BVMServersListViewController.h"
#import "BVMEmptyDetailViewController.h"

@interface BVMAppDelegate () <UISplitViewControllerDelegate>

@end

@implementation BVMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [[UIToolbar appearance] setBarTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkGrayColor]];

    UIViewController *rootVC;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UISplitViewController *vc = [[UISplitViewController alloc] init];
        UIViewController *emptyVC = [[BVMEmptyDetailViewController alloc] init];
        UINavigationController *detailNavigationVC = [[UINavigationController alloc] initWithRootViewController:emptyVC];
        vc.viewControllers = @[
            [[UINavigationController alloc] initWithRootViewController:[[BVMServersListViewController alloc] initWithDetailNavigationController:detailNavigationVC]],
            detailNavigationVC
        ];
        vc.delegate = self;
        rootVC = vc;
    } else {
        rootVC = [[UINavigationController alloc] initWithRootViewController:[[BVMServersListViewController alloc] initWithDetailNavigationController:nil]];
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

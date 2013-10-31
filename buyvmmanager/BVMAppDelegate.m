#import "BVMAppDelegate.h"

#import "BVMServersListViewController.h"
#import "BVMEmptyDetailViewController.h"

#import <BugSense-iOS/BugSenseController.h>
#import "AFNetworkActivityIndicatorManager.h"

#import "UIColor+BVMColors.h"

static NSString * const BVMBugSenseAPIKey = @"606b894f";

@interface BVMAppDelegate () <UISplitViewControllerDelegate>

@end

@implementation BVMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BugSenseController sharedControllerWithBugSenseAPIKey:BVMBugSenseAPIKey];
    [BugSenseController setLogMessagesCount:10];
    [BugSenseController setLogMessagesLevel:8];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self applyStyles];

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
        rootVC = [[UINavigationController alloc] initWithRootViewController:[[BVMServersListViewController alloc]
                                                                             initWithDetailNavigationController:nil]];
    }

    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    return YES;
}

#pragma mark - UI Management

- (void)applyStyles {
    [[UINavigationBar appearance] setTintColor:[UIColor bvm_tintColor]];
    [[UIToolbar appearance] setTintColor:[UIColor bvm_tintColor]];
}

#pragma mark UISplitViewControllerDelegate methods

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    // nope, just keep both VCs visible always.
    return NO;
}

@end

#import "BVMAppDelegate.h"
#import "UIColor+BVMColors.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "iRate.h"
#import "BVMServersListViewController.h"
#import "BVMEmptyDetailViewController.h"

@implementation BVMAppDelegate

+ (void)initialize
{
    [iRate sharedInstance].daysUntilPrompt = 10;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].remindPeriod = 2;
    [iRate sharedInstance].promptAgainForEachNewVersion = NO;
    [iRate sharedInstance].onlyPromptIfLatestVersion = YES;
    [iRate sharedInstance].applicationName = NSLocalizedString(@"BuyVM Manager", nil);
    [iRate sharedInstance].message = NSLocalizedString(@"If this app is useful, could you help me out by rating it in the App Store? It'll just take a minute. Thanks!", nil);
    [iRate sharedInstance].disableAlertViewResizing = NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [[UIToolbar appearance] setTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];

    UIViewController *rootVC;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UISplitViewController *vc = [[UISplitViewController alloc] init];
        vc.delegate = self;
        UIViewController *emptyVC = [[BVMEmptyDetailViewController alloc] init];
        UINavigationController *detailNavigationVC = [[UINavigationController alloc] initWithRootViewController:emptyVC];
        vc.viewControllers = @[
            [[UINavigationController alloc] initWithRootViewController:[[BVMServersListViewController alloc] initWithDetailNavigationController:detailNavigationVC]],
            detailNavigationVC
        ];
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

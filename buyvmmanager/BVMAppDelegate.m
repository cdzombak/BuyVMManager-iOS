#import "BVMAppDelegate.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "BVMServersListViewController.h"

@implementation BVMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    id navController = [[UINavigationController alloc] initWithRootViewController:[[BVMServersListViewController alloc] init]];
    self.window.rootViewController = navController;

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    [self.window makeKeyAndVisible];

    return YES;
}

@end

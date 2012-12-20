#import "BVMAppDelegate.h"

#import "AFNetworkActivityIndicatorManager.h"
@implementation BVMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;


    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

}

@end

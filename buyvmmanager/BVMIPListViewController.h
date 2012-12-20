#import <UIKit/UIKit.h>

@interface BVMIPListViewController : UITableViewController

/**
 * Designated initializer
 */
- (id)initWithServer:(NSString *)serverName ips:(NSArray *)ips;

@end

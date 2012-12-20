#import <UIKit/UIKit.h>

/**
 * This displays the detail for a set of "sizes" - bandwidth, disk, or memory.
 *
 * @discussion It probably needs a better name, but I can't think of one.
 */
@interface BVMSizesListViewController : UITableViewController

- (id)initWithServer:(NSString *)serverName
           statistic:(NSString *)statisticName
               total:(long long)totalBytes
                used:(long long)usedBytes
                free:(long long)freeBytes
         percentUsed:(NSUInteger)percentUsed;

@end

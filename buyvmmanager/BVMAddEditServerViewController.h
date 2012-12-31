#import <UIKit/UIKit.h>
#import "CDZViewControllerModalDismissal.h"

@interface BVMAddEditServerViewController : UITableViewController <CDZViewControllerModalDismissal>

@property (nonatomic, weak) id afterAddTarget;
@property (nonatomic, assign) SEL afterAddAction;

- (id)initForServerId:(NSString *)serverId;

@end

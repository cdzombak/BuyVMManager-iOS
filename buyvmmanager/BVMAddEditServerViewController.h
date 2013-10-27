#import "CDZViewControllerModalDismissal.h"

@interface BVMAddEditServerViewController : UITableViewController <CDZViewControllerModalDismissal>

@property (nonatomic, weak) id afterDataSaveTarget;
@property (nonatomic, assign) SEL afterDataSaveAction;

- (id)initForServerId:(NSString *)serverId;

@end

#import <UIKit/UIKit.h>

@interface BVMAddServerViewController : UITableViewController

@property (nonatomic, weak) id afterAddTarget;
@property (nonatomic, assign) SEL afterAddAction;

- (id)init;

@end

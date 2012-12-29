#import <UIKit/UIKit.h>

@interface BVMAddEditServerViewController : UITableViewController

@property (nonatomic, weak) id afterAddTarget;
@property (nonatomic, assign) SEL afterAddAction;

@property (nonatomic, weak) UIPopoverController *myPopoverController;

- (id)init;

@end

#import <UIKit/UIKit.h>

@interface CDZSubTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear;

- (id)initWithStyle:(UITableViewStyle)style;

@end

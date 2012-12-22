#import "CDZSubTableViewController.h"

@interface CDZSubTableViewController ()

@property (nonatomic, assign) UITableViewStyle tableViewStyle;

@end

@implementation CDZSubTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        self.tableViewStyle = style;
        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.autoresizesSubviews = YES;

    CGSize tableViewSize = self.view.bounds.size;
    if (self.navigationController.navigationBar) tableViewSize.height -= self.navigationController.navigationBar.frame.size.height;

    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){CGPointZero, tableViewSize} style:self.tableViewStyle];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.clearsSelectionOnViewWillAppear) {
        NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        if (selectedIndexPaths.count) {
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView flashScrollIndicators];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    [self.tableView setEditing:editing animated:animated];
}

@end

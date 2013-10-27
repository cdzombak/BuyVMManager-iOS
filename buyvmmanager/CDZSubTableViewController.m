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
#ifdef DEBUG
    self.view.backgroundColor = [UIColor yellowColor];
#endif

    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){CGPointZero, self.view.bounds.size} style:self.tableViewStyle];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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

#pragma mark Abstract Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(NO, @"%s is an abstract method and must be overriden\n%@",
             __PRETTY_FUNCTION__,
             [NSThread callStackSymbols]);
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"%s is an abstract method and must be overriden\n%@",
             __PRETTY_FUNCTION__,
             [NSThread callStackSymbols]);
    return nil;
}

@end

#import "BVMEmptyDetailViewController.h"
#import "BVMServersManager.h"
#import "UIColor+BVMColors.h"

@interface BVMEmptyDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation BVMEmptyDetailViewController

- (id)init
{
    self = [super initWithNibName:@"BVMEmptyDetailViewController" bundle:[NSBundle mainBundle]];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor bvm_tableViewBackgroundColor];
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;

    UIFont *font = [UIFont fontWithName:@"Jrhand" size:25];
    self.textLabel.font = font;
    self.textLabel.textColor = [UIColor darkTextColor];
    self.textLabel.shadowColor = [UIColor bvm_darkGrayTextShadowColor];
    self.textLabel.shadowOffset = CGSizeMake(0, 1.0);

    if ([BVMServersManager servers].count == 0) {
        self.textLabel.numberOfLines = 0;
        self.textLabel.text = NSLocalizedString(@"Tap the \"+\" button to add a VM.\n(If there's no \"+\" button, tap \"Edit\".)", nil);

        CGRect labelFrame = self.textLabel.frame;
        labelFrame.size.height *= 3;
        self.textLabel.frame = labelFrame;
    }
}

@end

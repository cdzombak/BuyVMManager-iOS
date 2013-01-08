#import "BVMAddEditServerViewController.h"
#import "BVMTextFieldTableViewCell.h"
#import "BVMServersManager.h"
#import "UIColor+BVMColors.h"
#import "ZBarSDK.h"

typedef NS_ENUM(NSUInteger, BVMAddServerTableViewRow) {
    BVMAddServerTableViewRowName = 0,
    BVMAddServerTableViewRowAPIKey,
    BVMAddServerTableViewRowAPIHash,
    BVMAddServerTableViewNumRows
};

@interface BVMAddEditServerViewController () <UITextFieldDelegate, ZBarReaderDelegate>

@property (nonatomic, copy) NSString *editingServerId;
@property (nonatomic, assign) BOOL didLoadEditingContent;
@property (nonatomic, copy) NSString *savedApiKey;
@property (nonatomic, copy) NSString *savedApiHash;

@property (nonatomic, readonly, strong) UITableViewCell *serverNameCell;
@property (nonatomic, readonly, strong) UITableViewCell *apiKeyCell;
@property (nonatomic, readonly, strong) UITableViewCell *apiHashCell;

@property (nonatomic, weak) UITextField *serverNameField;
@property (nonatomic, weak) UITextField *apiKeyField;
@property (nonatomic, weak) UITextField *apiHashField;

@property (nonatomic, readonly, strong) UIView *footerView;
@property (nonatomic, readonly, weak) UILabel *footerLabel;

@property (nonatomic, strong) ZBarReaderViewController *readerVc;
@property (nonatomic, weak) UITextField *currentReadingTextField;

@property (nonatomic, readonly) NSString *apiKeyHiddenText;
@property (nonatomic, readonly) NSString *apiHashHiddenText;

@end

@implementation BVMAddEditServerViewController

@synthesize footerView = _footerView,
            footerLabel = _footerLabel,
            dismissBlock = _dismissBlock,
            serverNameCell = _serverNameCell,
            apiKeyCell = _apiKeyCell,
            apiHashCell = _apiHashCell
            ;

- (id)initForServerId:(NSString *)serverId
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.editingServerId = serverId;
        self.didLoadEditingContent = NO;

        if (self.editingServerId) {
            self.title = NSLocalizedString(@"Edit VM", nil);
        } else {
            self.title = NSLocalizedString(@"Add VM", nil);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.allowsSelection = NO;
    self.tableView.tableFooterView = self.footerView;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelButtonTouched)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTouched)];

    self.tableView.backgroundColor = [UIColor bvm_tableViewBackgroundColor];
    self.tableView.backgroundView = nil;

    self.contentSizeForViewInPopover = CGSizeMake(320, self.footerView.frame.origin.y + self.footerView.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.editingServerId && !self.didLoadEditingContent) {
        NSString *serverName = [BVMServersManager servers][self.editingServerId];
        self.serverNameField.text = serverName;

        NSDictionary *credentials = [BVMServersManager credentialsForServerId:self.editingServerId];
        self.savedApiHash = credentials[kBVMServerKeyAPIHash];
        self.savedApiKey = credentials[kBVMServerKeyAPIKey];

        self.apiKeyField.text = self.apiKeyHiddenText;
        self.apiHashField.text = self.apiHashHiddenText;

        self.didLoadEditingContent = YES;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.footerLabel sizeToFit];
}

#pragma mark Interface Actions

- (void)scanQRForApiKey
{
    [self scanQRForField:self.apiKeyField];
}

- (void)scanQRForApiHash
{
    [self scanQRForField:self.apiHashField];
}

- (void)scanQRForField:(UITextField *)field
{
    self.currentReadingTextField = field;
    [field becomeFirstResponder];
    [self presentViewController:self.readerVc animated:YES completion:nil];
}

- (void)cancelButtonTouched
{
    if (self.dismissBlock) self.dismissBlock();
}

- (void)doneButtonTouched
{
    [self saveData];
}

#pragma mark Data

- (void)saveData
{
    NSArray *fields = @[self.serverNameField, self.apiKeyField, self.apiHashField];
    BOOL valid = YES;
    for (UITextField *field in fields) {
        if (!field.text || [field.text isEqualToString:@""]) {
            field.superview.superview.backgroundColor = [UIColor bvm_fieldErrorBackgroundColor];
            valid = NO;
        } else {
            field.superview.superview.backgroundColor = [UIColor whiteColor];
        }
    }

    if (!valid) return;

    NSString *apiKeyToSave = self.apiKeyField.text;
    NSString *apiHashToSave = self.apiHashField.text;
    if (self.editingServerId) {
        if ([self.apiKeyField.text isEqualToString:self.apiKeyHiddenText]) {
            apiKeyToSave = self.savedApiKey;
        }
        if ([self.apiHashField.text isEqualToString:self.apiHashHiddenText]) {
            apiHashToSave = self.savedApiHash;
        }
    }

    [BVMServersManager saveServerId:self.editingServerId
                               name:self.serverNameField.text
                                key:apiKeyToSave
                               hash:apiHashToSave];

    id afterDataSaveTarget = self.afterDataSaveTarget;
    if (afterDataSaveTarget && self.afterDataSaveAction && [afterDataSaveTarget respondsToSelector:self.afterDataSaveAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [afterDataSaveTarget performSelector:self.afterDataSaveAction];
#pragma clang diagnostic pop
    }

    for (UITextField *field in fields) {
        field.text = nil;
    }

    if (self.dismissBlock) self.dismissBlock();
}

#pragma mark ZBarReaderDelegate methods

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [self.readerVc dismissModalViewControllerAnimated:YES];

    id<NSFastEnumeration> results = info[ZBarReaderControllerResults];
    ZBarSymbol *bestResult = nil;
    for (ZBarSymbol *result in results) {
        if (result.quality > bestResult.quality) bestResult = result;
    }

    self.readerVc = nil;
    self.currentReadingTextField.text = bestResult.data;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == BVMAddServerTableViewRowName) {
        return self.serverNameCell;
    }
    else if (indexPath.row == BVMAddServerTableViewRowAPIKey) {
        return self.apiKeyCell;
    }
    else if (indexPath.row == BVMAddServerTableViewRowAPIHash) {
        return self.apiHashCell;
    }
    return nil;
}

#pragma mark UITableViewDelegate methods

// n/a

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.serverNameField) {
        [self.apiKeyField becomeFirstResponder];
        return NO;
    }
    if (textField == self.apiKeyField) {
        [self.apiHashField becomeFirstResponder];
        return NO;
    }
    if (textField == self.apiHashField) {
        [self.apiHashField resignFirstResponder];
        [self saveData];
        return NO;
    }
    return YES;
}

#pragma mark UI Help

- (UIView *)buildCameraViewWithHeight:(CGFloat)height tapSelector:(SEL)aSelector
{
    UIImage *cameraImage = [UIImage imageNamed:@"119-Camera"];
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, { cameraImage.size.width * 1.6 , height } }];

    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:aSelector];
    tapRecognizer.numberOfTapsRequired = 1;
    [view addGestureRecognizer:tapRecognizer];

    UIImageView *iv = [[UIImageView alloc] initWithImage:cameraImage];
    iv.center = view.center;
    [view addSubview:iv];

    return view;
}

#pragma mark Property Overrides

- (UITableViewCell *)serverNameCell
{
    if (!_serverNameCell) {
        BVMTextFieldTableViewCell *cell = [[BVMTextFieldTableViewCell alloc] initWithReuseIdentifier:@"Cell"];
        UITextField *tf = cell.textField;
        tf.placeholder = NSLocalizedString(@"Server Name", nil);
        tf.returnKeyType = UIReturnKeyNext;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.delegate = self;
        self.serverNameField = tf;
        _serverNameCell = cell;
    }
    return _serverNameCell;
}

- (UITableViewCell *)apiKeyCell
{
    if (!_apiKeyCell) {
        BVMTextFieldTableViewCell *cell = [[BVMTextFieldTableViewCell alloc] initWithReuseIdentifier:@"Cell"];
        UITextField *tf = cell.textField;
        tf.placeholder = NSLocalizedString(@"API Key", nil);
        tf.returnKeyType = UIReturnKeyNext;
        CGFloat height = [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        tf.rightView = [self buildCameraViewWithHeight:height
                                           tapSelector:@selector(scanQRForApiKey)];
        tf.rightViewMode = UITextFieldViewModeUnlessEditing;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.delegate = self;
        self.apiKeyField = tf;
        _apiKeyCell = cell;
    }
    return _apiKeyCell;
}

- (UITableViewCell *)apiHashCell
{
    if (!_apiHashCell) {
        BVMTextFieldTableViewCell *cell = [[BVMTextFieldTableViewCell alloc] initWithReuseIdentifier:@"Cell"];
        UITextField *tf = cell.textField;
        tf.placeholder = NSLocalizedString(@"API Hash", nil);
        tf.returnKeyType = UIReturnKeyDone;
        CGFloat height = [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        tf.rightView = [self buildCameraViewWithHeight:height
                                           tapSelector:@selector(scanQRForApiHash)];
        tf.rightViewMode = UITextFieldViewModeUnlessEditing;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.delegate = self;
        self.apiHashField = tf;
        _apiHashCell = cell;
    }
    return _apiHashCell;
}

- (UIView *)footerView
{
    if (!_footerView) {
        NSString *notes = NSLocalizedString(@"Server name may be anything you like.\nAPI Key and API Hash must be entered exactly as they appear in the VPS Control Panel at https://manage.buyvm.net/ clientapi.php.\nCopying these from elsewhere - an email, for example - is easiest.\nYou may scan QR codes for these fields by tapping the camera icon.", nil);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.bounds.size.width-36, 170)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.shadowColor = [UIColor bvm_darkGrayTextShadowColor];
        label.shadowOffset = CGSizeMake(0, 1.0);
        label.text = notes;
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:15.0];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _footerLabel = label;

        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, label.bounds.size.height)];
        _footerView.backgroundColor = [UIColor clearColor];
        _footerView.autoresizesSubviews = YES;
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_footerView addSubview:label];
    }
    return _footerView;
}

- (ZBarReaderViewController *)readerVc
{
    if (!_readerVc) {
        _readerVc = [ZBarReaderViewController new];
        _readerVc.readerDelegate = self;
        _readerVc.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;

        [_readerVc.scanner setSymbology:0 config:ZBAR_CFG_ENABLE to:0];
        [_readerVc.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];

        _readerVc.readerView.zoom = 1.0;
    }
    return _readerVc;
}

- (NSString *)apiKeyHiddenText
{
    return NSLocalizedString(@"API Key Hidden", nil);
}

- (NSString *)apiHashHiddenText
{
    return NSLocalizedString(@"API Hash Hidden", nil);
}

@end

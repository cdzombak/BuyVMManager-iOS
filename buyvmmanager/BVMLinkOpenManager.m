#import "BVMLinkOpenManager.h"

static NSString *kBVMBrowserPrefsKey = @"BVMBrowserPrefsKey";

static NSString * BVMBrowserNames[BVMNumBrowsers];

__attribute__((constructor)) static void __BVMBrowserConstantsInit(void)
{
    @autoreleasepool {
        BVMBrowserNames[BVMBrowserSafari] = NSLocalizedString(@"Safari", nil);
        BVMBrowserNames[BVMBrowserOnePassword] = NSLocalizedString(@"1Password", nil);
        BVMBrowserNames[BVMBrowserChrome] = NSLocalizedString(@"Google Chrome", nil);
    }
}

@implementation BVMLinkOpenManager

#pragma mark Browser availability

+ (BOOL)browserAvailable:(BVMBrowser)browser
{
    switch(browser) {
        case BVMBrowserSafari:
            return YES;
        case BVMBrowserChrome:
            return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://google.com"]];
        case BVMBrowserOnePassword:
            return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"onepassword://search"]];
        default:
            NSLog(@"Unknown browser %d in %s", browser, __PRETTY_FUNCTION__);
            return NO;
    }
}

#pragma mark Default browser management

+ (BVMBrowser)selectedBrowser {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kBVMBrowserPrefsKey];
}

+ (void)setSelectedBrowser:(BVMBrowser)browser
{
    [[NSUserDefaults standardUserDefaults] setInteger:browser forKey:kBVMBrowserPrefsKey];
}

#pragma mark URL Actions

+ (void)openURL:(NSURL *)url
{
    NSString *replacementScheme = [BVMLinkOpenManager replacementSchemeForScheme:url.scheme];

    if (replacementScheme) {
        // https://developers.google.com/chrome/mobile/docs/ios-links
        NSString *absoluteString = [url absoluteString];
        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
        NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
        NSString *replacedURLString = [replacementScheme stringByAppendingString:urlNoScheme];
        url = [NSURL URLWithString:replacedURLString];
    }

    [[UIApplication sharedApplication] openURL:url];
}

+ (void)openURLString:(NSString *)urlString
{
    [BVMLinkOpenManager openURL:[NSURL URLWithString:urlString]];
}

+ (NSString *)replacementSchemeForScheme:(NSString *)scheme
{
    NSString *urlScheme = [scheme lowercaseString];
    NSString *replacementScheme = nil;

    BVMBrowser selectedBrowser = [BVMLinkOpenManager selectedBrowser];
    if (selectedBrowser == BVMBrowserSafari) return nil;

    if (selectedBrowser == BVMBrowserChrome && ![BVMLinkOpenManager browserAvailable:BVMBrowserChrome]) return nil;
    if (selectedBrowser == BVMBrowserOnePassword && ![BVMLinkOpenManager browserAvailable:BVMBrowserOnePassword]) return nil;

    if ([urlScheme isEqualToString:@"http"]) {
        if (selectedBrowser == BVMBrowserOnePassword) replacementScheme = @"ophttp";
        else if (selectedBrowser == BVMBrowserChrome) replacementScheme = @"googlechrome";
    } else if ([urlScheme isEqualToString:@"https"]) {
        if (selectedBrowser == BVMBrowserOnePassword) replacementScheme = @"ophttps";
        else if (selectedBrowser == BVMBrowserChrome) replacementScheme = @"googlechromes";
    }

    return replacementScheme;
}

#pragma mark UI/Naming

+ (NSString *)nameForBrowser:(BVMBrowser)browser
{
    NSParameterAssert(browser < BVMNumBrowsers);
    NSParameterAssert(browser >= 0);

    return BVMBrowserNames[browser];
}

@end

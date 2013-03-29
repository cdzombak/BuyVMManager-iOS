#import "BVMLinkOpenManager.h"

static NSString *kBVMBrowserPrefsKey = @"BVMBrowserPrefsKey";

static NSString *kBVMBrowserNames[BVMNumBrowsers];
static NSURL *kBVMBrowserTestURLs[BVMNumBrowsers];

__attribute__((constructor)) static void __BVMBrowserConstantsInit(void)
{
    @autoreleasepool {
        kBVMBrowserNames[BVMBrowserSafari] = NSLocalizedString(@"Safari", nil);
        kBVMBrowserNames[BVMBrowserOnePassword] = NSLocalizedString(@"1Password", nil);
        kBVMBrowserNames[BVMBrowserChrome] = NSLocalizedString(@"Google Chrome", nil);

        kBVMBrowserTestURLs[BVMBrowserSafari] = [NSURL URLWithString:@"http://google.com"];
        kBVMBrowserTestURLs[BVMBrowserChrome] = [NSURL URLWithString:@"googlechrome://google.com"];
        kBVMBrowserTestURLs[BVMBrowserOnePassword] = [NSURL URLWithString:@"onepassword://search"];
    }
}

@implementation BVMLinkOpenManager

#pragma mark Browser availability

+ (BOOL)browserAvailable:(BVMBrowser)browser
{
    if (browser >= BVMNumBrowsers || browser < 0) {
        NSLog(@"Unknown browser %d in %s", browser, __PRETTY_FUNCTION__);
        return NO;
    }

    NSURL *testURL = kBVMBrowserTestURLs[browser];
    return [[UIApplication sharedApplication] canOpenURL:testURL];
}

#pragma mark Default browser management

+ (BVMBrowser)selectedBrowser {
    // note: if not set, this falls back to 0 == BVMBrowserSafari
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
    if (browser >= BVMNumBrowsers || browser < 0) {
        NSLog(@"Unknown browser %d in %s", browser, __PRETTY_FUNCTION__);
        return nil;
    }

    return kBVMBrowserNames[browser];
}

@end

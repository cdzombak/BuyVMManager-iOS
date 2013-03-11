#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BVMBrowser) {
    BVMBrowserSafari = 0,
    BVMBrowserChrome,
    BVMBrowserOnePassword,
    BVMNumBrowsers
};

@interface BVMLinkOpenManager : NSObject

+ (BOOL)browserAvailable:(BVMBrowser)browser;

+ (BVMBrowser)selectedBrowser;
+ (void)setSelectedBrowser:(BVMBrowser)browser;

/**
 * Open the given URL.
 *
 * If HTTP or HTTPS, uses the defaut browser.
 */
+ (void)openURL:(NSURL *)url;
+ (void)openURLString:(NSString *)urlString;

+ (NSString *)nameForBrowser:(BVMBrowser)browser;

@end

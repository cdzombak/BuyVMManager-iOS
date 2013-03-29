#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BVMBrowser) {
    BVMBrowserSafari = 0,
    BVMBrowserChrome,
    BVMBrowserOnePassword,
    BVMNumBrowsers
};

@interface BVMLinkOpenManager : NSObject

/**
 * Returns YES if the given browser is available on this device.
 */
+ (BOOL)browserAvailable:(BVMBrowser)browser;

/**
 * Returns the user's selected default browser.
 */
+ (BVMBrowser)selectedBrowser;

/**
 * Sets the user's selected default browser.
 */
+ (void)setSelectedBrowser:(BVMBrowser)browser;

/**
 * Opens the given URL.
 *
 * If HTTP or HTTPS, uses the defaut browser.
 */
+ (void)openURL:(NSURL *)url;
+ (void)openURLString:(NSString *)urlString;

/**
 * Returns the human-friendly name for the given browser.
 */
+ (NSString *)nameForBrowser:(BVMBrowser)browser;

@end

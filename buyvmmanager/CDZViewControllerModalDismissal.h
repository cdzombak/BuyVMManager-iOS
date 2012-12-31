#import <Foundation/Foundation.h>

typedef void (^CDZDismissBlock)(void);

@protocol CDZViewControllerModalDismissal <NSObject>

@property (nonatomic, copy) CDZDismissBlock dismissBlock;

@end

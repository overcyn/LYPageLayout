#import <UIKit/UIKit.h>
@protocol LYPage;

@interface LYPageViewController : UIViewController
@property (nonatomic, strong) id<LYPage> page;
@end

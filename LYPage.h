#import <UIKit/UIKit.h>
@protocol LYPageDelegate;

@protocol LYPage <NSObject>
@property (nonatomic, readonly) NSArray *sections;
@optional
@property (nonatomic, weak) id<LYPageDelegate> delegate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIView *titleView;
@property (nonatomic, readonly) NSArray *rightBarButtonItems;
@property (nonatomic, readonly) NSArray *leftBarButtonItems;
@property (nonatomic, readonly) UIStatusBarStyle preferredStatusBarStyle;
@property (nonatomic, readonly) BOOL hidesBackButton;
@property (nonatomic, readonly) BOOL hidesNavigationBar;
@property (nonatomic, readonly) BOOL scrollEnabled;
- (void)pageWillAppear;
- (void)pageWillDisappear;
- (void)pageDidAppear;
- (void)pageDidDisappear;
@end

// This is the interface that LYPageViewController exposes to the LYPages
@protocol LYPageDelegate <NSObject>
- (void)pageDidUpdate:(id<LYPage>)page;
- (UIViewController *)parentViewControllerForPage:(id<LYPage>)page;
@end

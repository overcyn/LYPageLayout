#import <UIKit/UIKit.h>
@class LYCollectionViewLayout;

@interface LYCollectionViewBehaviorOutput : NSObject
- (id)initWithAttributes:(NSArray *)attributes height:(CGFloat)height scrollIndicatorInsets:(UIEdgeInsets)insets;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic) CGFloat height;
@property (nonatomic) UIEdgeInsets scrollIndicatorInsets;
@end

@interface LYCollectionViewBehaviorInput : NSObject
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LYCollectionViewLayout *layout;
@property (nonatomic) NSInteger section;
@property (nonatomic) CGFloat y;
@end

@protocol LYCollectionViewBehavior <NSObject>
- (LYCollectionViewBehaviorOutput *)getAttributes:(LYCollectionViewBehaviorInput *)input;
- (void)updateAttributes:(NSArray *)attributes withInput:(LYCollectionViewBehaviorInput *)input;
@end

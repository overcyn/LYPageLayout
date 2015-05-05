#import <UIKit/UIKit.h>

@interface UIScrollView (LYAdditions)
@property (nonatomic) UIEdgeInsets LYScrollIndicatorInsets;
@end

@interface UICollectionView (LYAdditions)
- (void)LYDeselectAllItems;
@end

NSIndexSet *LYIndexPathsToIndexSet(NSArray *indexPaths, NSInteger section);

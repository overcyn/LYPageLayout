#import <UIKit/UIKit.h>
#import "LYCollectionViewBehavior.h"

@interface LYCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic) CGPoint offset;
@end

@interface LYCollectionViewLayout : UICollectionViewLayout
@end

@protocol LYCollectionViewDelegateLayout <UICollectionViewDelegate>
- (id<LYCollectionViewBehavior>)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout behaviorForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

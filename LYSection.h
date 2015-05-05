#import <UIKit/UIKit.h>
#import "LYCollectionViewLayout.h"
@protocol LYSectionDelegate;

@protocol LYSection <NSObject>
+ (Class)controllerClass;
@end

@protocol LYSectionController <NSObject>
@required
- (id)initWithSection:(id<LYSection>)section;
@property (nonatomic, readonly) id<LYSection> section;
@property (nonatomic, weak) id<LYSectionDelegate> delegate;
- (void)setup;
- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index;
- (CGSize)sizeForItemAtIndex:(NSInteger)index thatFits:(CGSize)size;
@optional
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) id<LYCollectionViewBehavior> behavior;
- (void)selectItemAtIndex:(NSInteger)index;
@end

// This is the interface that LYPageViewController exposes to the LYSectionControllers
@protocol LYSectionDelegate <NSObject>
- (UIViewController *)parentViewControllerForSection:(id<LYSectionController>)section;
- (UICollectionView *)collectionViewForSection:(id<LYSectionController>)section;
- (NSIndexSet *)visibleIndexesForSection:(id<LYSectionController>)section;
- (void)section:(id<LYSectionController>)section registerClass:(Class)class forCellWithReuseIdentifier:(NSString *)reuseId;
- (UICollectionViewCell *)section:(id<LYSectionController>)section dequeueReusableCellWithReuseIdentifier:(NSString *)reuseId forIndex:(NSInteger)index;
- (UICollectionViewCell *)section:(id<LYSectionController>)section visibleCellForItemAtIndex:(NSInteger)index;
- (UICollectionViewCell *)section:(id<LYSectionController>)section cellForItemAtIndex:(NSInteger)index;
- (void)section:(id<LYSectionController>)section reloadItemsAtIndexes:(NSIndexSet *)index;
@end

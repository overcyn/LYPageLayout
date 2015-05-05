#import "LYCollectionViewLayout.h"
#import "LYCollectionViewBehavior.h"
#import "LYCollectionViewCustomBehavior.h"
#import "UIKit+LYAdditions.h"

@implementation LYCollectionViewLayout {
    CGSize _sizeAtSetup;
    BOOL _valid;
    CGSize _contentSize;
    NSArray *_attributesArray;
    LYDefaultBehavior *_defaultBehavior;
}

+ (Class)layoutAttributesClass {
    return [LYCollectionViewLayoutAttributes class];
}

- (id)init {
    if ((self = [super init])) {
        _defaultBehavior = [[LYDefaultBehavior alloc] init];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    if (!CGSizeEqualToSize([[self collectionView] frame].size, _sizeAtSetup)) {
        _valid = NO;
    }
    if (!_valid) {
        [self _setup];
    }
    [self _updateAttributes];
}

- (CGSize)collectionViewContentSize {
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [_attributesArray count]; i++) {
        for (NSInteger j = 0; j < [_attributesArray[i] count]; j++) {
            UICollectionViewLayoutAttributes *attributes = _attributesArray[i][j];
            if (CGRectIntersectsRect([attributes frame], rect)) {
                [attributesArray addObject:attributes];
            }
        }
    }
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _attributesArray[[indexPath section]][[indexPath item]];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    [super invalidateLayoutWithContext:context];
    if ([context invalidateEverything] || [context invalidateDataSourceCounts]) {
        _valid = NO;
    }
}

#pragma mark - Internal

- (void)_setup {
    UICollectionView *view = [self collectionView];
    CGSize size = [view frame].size;
    id<UICollectionViewDataSource> dataSource = [view dataSource];
    id<LYCollectionViewDelegateLayout> delegate = (id)[view delegate];
    NSInteger sections = [dataSource numberOfSectionsInCollectionView:view];
    
    CGFloat y = 0;
    UIEdgeInsets scrollIndicatorInsets = UIEdgeInsetsZero;
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < sections; i++) {
        id<LYCollectionViewBehavior> sectionBehavior = [delegate collectionView:view layout:self behaviorForSectionAtIndex:i] ?: _defaultBehavior;
        LYCollectionViewBehaviorInput *input = [[LYCollectionViewBehaviorInput alloc] init];
        [input setCollectionView:view];
        [input setLayout:self];
        [input setSection:i];
        [input setY:y];
        
        LYCollectionViewBehaviorOutput *output = [sectionBehavior getAttributes:input];
        [attributesArray addObject:[output attributes]];
        y += [output height];
        scrollIndicatorInsets.top += [output scrollIndicatorInsets].top;
    }
    
    _contentSize = CGSizeMake(size.width, y);
    _attributesArray = attributesArray;
    _sizeAtSetup = size;
    _valid = YES;
    [view setLYScrollIndicatorInsets:scrollIndicatorInsets];
}

- (void)_updateAttributes {
    for (NSInteger i = 0; i < [[self collectionView] numberOfSections]; i++) {
        id<LYCollectionViewBehavior> sectionBehavior = [(id)[[self collectionView] delegate] collectionView:[self collectionView] layout:self behaviorForSectionAtIndex:i];
        if (sectionBehavior) {
            LYCollectionViewBehaviorInput *input = [[LYCollectionViewBehaviorInput alloc] init];
            [input setCollectionView:[self collectionView]];
            [input setLayout:self];
            [input setSection:i];
            [sectionBehavior updateAttributes:_attributesArray[i] withInput:input];
        }
    }
}

@end

@implementation LYCollectionViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    LYCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];
    [copy setOffset:[self offset]];
    return copy;
}

@end

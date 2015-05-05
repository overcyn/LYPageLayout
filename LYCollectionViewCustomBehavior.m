#import "LYCollectionViewCustomBehavior.h"
#import "LYCollectionViewLayout.h"
#import "LYSection.h"

#define BACKGROUND_Z    -1
#define DEFAULT_Z       0
#define CATCHES_Z       1
#define HEADER_Z        2
#define FIXED_Z         10000
#define FLOATING_Z      10001
#define FADE_HEIGHT     50

@implementation LYDefaultBehavior {
    UIEdgeInsets _insets;
    CGFloat _lineSpacing;
    CGFloat _interitemSpacing;
    BOOL _padding;
    BOOL _fades;
    CGFloat _fadeDistance;
}

@synthesize insets = _insets;
@synthesize lineSpacing = _lineSpacing;
@synthesize interitemSpacing = _interitemSpacing;
@synthesize padding = _padding;
@synthesize fades = _fades;
@synthesize fadeDistance = _fadeDistance;

- (LYCollectionViewBehaviorOutput *)getAttributes:(LYCollectionViewBehaviorInput *)input {
    NSMutableArray *attributes = [NSMutableArray array];
    CGFloat x = _insets.left;
    CGFloat maxX = [[input collectionView] frame].size.width - _insets.right;
    CGFloat y = [input y] + _insets.top;
    CGFloat nextRowY = y + _lineSpacing;
    for (NSInteger i = 0; i < [[input collectionView] numberOfItemsInSection:[input section]]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:[input section]];
        CGSize size = [(id)[[input collectionView] delegate] collectionView:[input collectionView] layout:[input layout] sizeForItemAtIndexPath:indexPath];
        if (x + size.width > maxX && x != _insets.left) {
            x = _insets.left;
            y = nextRowY;
            nextRowY = y + _lineSpacing;
        }
        
        CGRect f = CGRectMake(x, y, size.width, size.height);
        LYCollectionViewLayoutAttributes *attr = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        [attr setFrame:f];
        [attributes addObject:attr];
        
        nextRowY = MAX(nextRowY, CGRectGetMaxY(f) + _lineSpacing);
        x = CGRectGetMaxX(f) + _interitemSpacing;
    }
    y = nextRowY - _lineSpacing + _insets.bottom;
    
    return [[LYCollectionViewBehaviorOutput alloc] initWithAttributes:attributes height:_padding ? 0 : y - [input y] scrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)updateAttributes:(NSArray *)attributes withInput:(LYCollectionViewBehaviorInput *)input {
    if (_fades) {
        UIEdgeInsets scrollInsets = [[input collectionView] scrollIndicatorInsets];
        CGPoint contentOffset = [[input collectionView] contentOffset];
        CGFloat fadeY = [[input collectionView] frame].size.height - scrollInsets.top - scrollInsets.bottom - _fadeDistance;
        
        for (LYCollectionViewLayoutAttributes *i in attributes) {
            CGFloat distanceFromTop = [i frame].origin.y - (contentOffset.y + scrollInsets.top);
            if (distanceFromTop < fadeY - FADE_HEIGHT) {
                [i setHidden:YES];
            } else if (distanceFromTop < fadeY) {
                [i setHidden:NO];
                [i setAlpha:1 - (fadeY - distanceFromTop) / FADE_HEIGHT];
            } else {
                [i setHidden:NO];
                [i setAlpha:1];
            }
        }
    }
}

@end

@implementation LYFloatingBehavior {
    CGPoint _floatingOffset;
    UIRectEdge _rectEdge;
}

@synthesize floatingOffset = _floatingOffset;
@synthesize rectEdge = _rectEdge;

- (LYCollectionViewBehaviorOutput *)getAttributes:(LYCollectionViewBehaviorInput *)input {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:[input section]];
    CGSize size = [(id)[[input collectionView] delegate] collectionView:[input collectionView] layout:[input layout] sizeForItemAtIndexPath:indexPath];
    
    CGRect f = CGRectMake(0, 0, size.width, size.height); // handle y position in updateAttributes:
    if ((_rectEdge & UIRectEdgeLeft) == UIRectEdgeLeft) {
        f.origin.x = _floatingOffset.x;
    } else if ((_rectEdge & UIRectEdgeRight) == UIRectEdgeRight) {
        f.origin.x = [[input collectionView] frame].size.width - _floatingOffset.x - size.width;
    }
    LYCollectionViewLayoutAttributes *attr = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    [attr setFrame:f];
    [attr setZIndex:FLOATING_Z];
    
    return [[LYCollectionViewBehaviorOutput alloc] initWithAttributes:@[attr] height:0 scrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)updateAttributes:(NSArray *)attributes withInput:(LYCollectionViewBehaviorInput *)input {
    UIEdgeInsets scrollInsets = [[input collectionView] scrollIndicatorInsets];
    CGPoint contentOffset = [[input collectionView] contentOffset];
    
    LYCollectionViewLayoutAttributes *attr = attributes[0];
    CGRect f = [attr frame];
    if ((_rectEdge & UIRectEdgeTop) == UIRectEdgeTop) {
        f.origin.y = contentOffset.y + scrollInsets.top + _floatingOffset.y;
    } else if ((_rectEdge & UIRectEdgeBottom) == UIRectEdgeBottom) {
        f.origin.y = contentOffset.y + [[input collectionView] frame].size.height - scrollInsets.bottom - _floatingOffset.y - f.size.height;
    }
    [attr setFrame:f];
}

@end

@implementation LYBackgroundBehavior

- (LYCollectionViewBehaviorOutput *)getAttributes:(LYCollectionViewBehaviorInput *)input {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:[input section]];
    CGSize size = [[input collectionView] frame].size;
    
    LYCollectionViewLayoutAttributes *attr = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    [attr setFrame:CGRectMake(0, 0, size.width, size.height)];
    [attr setZIndex:BACKGROUND_Z];
    
    return [[LYCollectionViewBehaviorOutput alloc] initWithAttributes:@[attr] height:0 scrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)updateAttributes:(NSArray *)attributes withInput:(LYCollectionViewBehaviorInput *)input {
    CGPoint contentOffset = [[input collectionView] contentOffset];
    
    LYCollectionViewLayoutAttributes *attr = attributes[0];
    CGRect f = [attr frame];
    f.origin.y = contentOffset.y;
    [attr setFrame:f];
}

@end

@implementation LYHeaderBehavior

- (LYCollectionViewBehaviorOutput *)getAttributes:(LYCollectionViewBehaviorInput *)input {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:[input section]];
    CGSize size = [(id)[[input collectionView] delegate] collectionView:[input collectionView] layout:[input layout] sizeForItemAtIndexPath:indexPath];
    
    LYCollectionViewLayoutAttributes *attr = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    [attr setFrame:CGRectMake(0, [input y], size.width, size.height)];
    [attr setZIndex:HEADER_Z + [input section]];
    [attr setOffset:CGPointMake(0, [input y])];
    
    return [[LYCollectionViewBehaviorOutput alloc] initWithAttributes:@[attr] height:size.height scrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)updateAttributes:(NSArray *)attributes withInput:(LYCollectionViewBehaviorInput *)input {
    UIEdgeInsets scrollInsets = [[input collectionView] scrollIndicatorInsets];
    CGPoint contentOffset = [[input collectionView] contentOffset];
    
    LYCollectionViewLayoutAttributes *attr = attributes[0];
    CGRect f = [attr frame];
    if ([attr offset].y > contentOffset.y + scrollInsets.top) {
        f.origin.y = [attr offset].y;
    } else {
        f.origin.y = contentOffset.y + scrollInsets.top;
    }
    [attr setFrame:f];
}

@end

@implementation LYFixedBehavior

- (LYCollectionViewBehaviorOutput *)getAttributes:(LYCollectionViewBehaviorInput *)input {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:[input section]];
    CGSize size = [(id)[[input collectionView] delegate] collectionView:[input collectionView] layout:[input layout] sizeForItemAtIndexPath:indexPath];
    
    LYCollectionViewLayoutAttributes *attr = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    [attr setFrame:CGRectMake(0, [input y], size.width, size.height)];
    [attr setZIndex:FIXED_Z];
    
    return [[LYCollectionViewBehaviorOutput alloc] initWithAttributes:@[attr] height:size.height scrollIndicatorInsets:UIEdgeInsetsMake(size.height, 0, 0, 0)];
}

- (void)updateAttributes:(NSArray *)attributes withInput:(LYCollectionViewBehaviorInput *)input {
    UIEdgeInsets contentInset = [[input collectionView] contentInset];
    CGPoint contentOffset = [[input collectionView] contentOffset];
    
    LYCollectionViewLayoutAttributes *attr = attributes[0];
    CGRect f = [attr frame];
    f.origin.y = contentOffset.y + contentInset.top;
    [attr setFrame:f];
}

@end

@implementation LYCatchesBehavior

- (LYCollectionViewBehaviorOutput *)getAttributes:(LYCollectionViewBehaviorInput *)input {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:[input section]];
    CGSize size = [(id)[[input collectionView] delegate] collectionView:[input collectionView] layout:[input layout] sizeForItemAtIndexPath:indexPath];
    
    LYCollectionViewLayoutAttributes *attr = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    [attr setFrame:CGRectMake(0, [input y], size.width, size.height)];
    [attr setOffset:CGPointMake(0, [input y])];
    [attr setZIndex:CATCHES_Z];
    
    return [[LYCollectionViewBehaviorOutput alloc] initWithAttributes:@[attr] height:size.height scrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)updateAttributes:(NSArray *)attributes withInput:(LYCollectionViewBehaviorInput *)input {
    UIEdgeInsets scrollInsets = [[input collectionView] scrollIndicatorInsets];
    CGPoint contentOffset = [[input collectionView] contentOffset];
    
    LYCollectionViewLayoutAttributes *attr = attributes[0];
    CGRect f = [attr frame];
    if ([attr offset].y < contentOffset.y + scrollInsets.top) {
        f.origin.y = [attr offset].y;
    } else {
        f.origin.y = contentOffset.y + scrollInsets.top;
    }
    [attr setFrame:f];
}

@end

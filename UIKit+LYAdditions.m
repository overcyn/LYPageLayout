#import "UIKit+LYAdditions.h"
#import <objc/runtime.h>

#define SCROLL_INDICATOR_INSETS_KEY         @"LYScrollIndicatorInsets"

@implementation UIScrollView (LYAdditions)

- (UIEdgeInsets)LYScrollIndicatorInsets {
    NSValue *value = objc_getAssociatedObject(self, SCROLL_INDICATOR_INSETS_KEY);
    if (!value) {
        return UIEdgeInsetsZero;
    }
    return [value UIEdgeInsetsValue];
}

- (void)setLYScrollIndicatorInsets:(UIEdgeInsets)value {
    UIEdgeInsets storedInsets = [self LYScrollIndicatorInsets];
    UIEdgeInsets currentInsets = [self scrollIndicatorInsets];
    currentInsets.top += value.top - storedInsets.top;
    currentInsets.left += value.left - storedInsets.left;
    currentInsets.right += value.right - storedInsets.right;
    currentInsets.bottom += value.bottom - storedInsets.bottom;
    [self setScrollIndicatorInsets:currentInsets];
    
    objc_setAssociatedObject(self, SCROLL_INDICATOR_INSETS_KEY, [NSValue valueWithUIEdgeInsets:value], OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation UICollectionView (LYAdditions)

- (void)LYDeselectAllItems {
    for (NSIndexPath *i in [self indexPathsForSelectedItems]) {
        [self deselectItemAtIndexPath:i animated:YES];
    }
}

@end

NSIndexSet *LYIndexPathsToIndexSet(NSArray *indexPaths, NSInteger section) {
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (NSIndexPath *i in indexPaths) {
        if ([i section] == section) {
            [indexSet addIndex:[i indexAtPosition:1]];
        }
    }
    return indexSet;
}

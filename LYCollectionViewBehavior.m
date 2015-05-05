#import "LYCollectionViewBehavior.h"

@implementation LYCollectionViewBehaviorInput
@end

@implementation LYCollectionViewBehaviorOutput : NSObject
- (id)initWithAttributes:(NSArray *)attributes height:(CGFloat)height scrollIndicatorInsets:(UIEdgeInsets)insets {
    if ((self = [super init])) {
        [self setAttributes:attributes];
        [self setHeight:height];
        [self setScrollIndicatorInsets:insets];
    }
    return self;
}
@end

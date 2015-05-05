#import "LYCollectionViewBehavior.h"

// A basic grid
@interface LYDefaultBehavior : NSObject <LYCollectionViewBehavior>
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat interitemSpacing;

// Disable extending content size
@property (nonatomic) BOOL padding;

// Fades out a certain distance from the bottom
@property (nonatomic) BOOL fades;
@property (nonatomic) CGFloat fadeDistance;
@end

// Floats at a position. Only supports 1 item.
@interface LYFloatingBehavior : NSObject <LYCollectionViewBehavior>
@property (nonatomic) CGPoint floatingOffset;
@property (nonatomic) UIRectEdge rectEdge;
@end

// Fixed at background. Only supports 1 item.
@interface LYBackgroundBehavior : NSObject <LYCollectionViewBehavior>
@end

// Behaves like UITableViewSectionHeader. Only supports 1 item.
@interface LYHeaderBehavior : NSObject <LYCollectionViewBehavior>
@end

// Permanently pins to the top, adjusting the scroll indicators. Only supports 1 item.
@interface LYFixedBehavior : NSObject <LYCollectionViewBehavior>
@end

// If below the navbar, pins to top, otherwise scrolls normally. Only supports 1 item.
@interface LYCatchesBehavior : NSObject <LYCollectionViewBehavior>
@end

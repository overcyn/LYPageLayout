#import "LYPageViewController.h"
#import "LYSection.h"
#import "LYPage.h"
#import "LYCollectionViewLayout.h"
#import "UIKit+LYAdditions.h"

@interface LYPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, LYSectionDelegate, LYPageDelegate>
@end

@implementation LYPageViewController {
    NSArray *_sections;
    NSArray *_sectionControllers;
    UICollectionView *_collectionView;
    id<LYPage> _page;
}

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle {
    if ((self = [super initWithNibName:name bundle:bundle])) {
        _sections = @[];
        _sectionControllers = @[];
    }
    return self;
}

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

#pragma mark - API

@synthesize page = _page;

- (void)setPage:(id<LYPage>)page {
    _page = page;
    if ([_page respondsToSelector:@selector(setDelegate:)]) {
        [_page setDelegate:self];
    }
    [self pageDidUpdate:_page];
}

#pragma mark - UIViewController

- (void)loadView {
    LYCollectionViewLayout *layout = [[LYCollectionViewLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setAlwaysBounceVertical:YES];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    if ([_page respondsToSelector:@selector(scrollEnabled)]) {
        [_collectionView setScrollEnabled:[_page scrollEnabled]];
    }
    [self setView:_collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_collectionView LYDeselectAllItems];
    if ([_page respondsToSelector:@selector(pageWillAppear)]) {
        [_page pageWillAppear];
    }
    if ([_page respondsToSelector:@selector(hidesNavigationBar)] && [_page hidesNavigationBar]) {
        [[self navigationController] setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([_page respondsToSelector:@selector(pageDidAppear)]) {
        [_page pageDidAppear];
    }
    
    // KD: Hack to fix missing nav bar when cancelling out of swipe back gesture. Something to do with changing statusBar styles.
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_page respondsToSelector:@selector(hidesNavigationBar)] && [_page hidesNavigationBar]) {
            [[self navigationController] setNavigationBarHidden:YES animated:NO];
        } else {
            [[self navigationController] setNavigationBarHidden:NO animated:NO];
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([_page respondsToSelector:@selector(pageWillDisappear)]) {
        [_page pageWillDisappear];
    }
    if ([_page respondsToSelector:@selector(hidesNavigationBar)] && [_page hidesNavigationBar] && [[self navigationController] topViewController] != self) { // KD: WEIRD HACK
        [[self navigationController] setNavigationBarHidden:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([_page respondsToSelector:@selector(pageDidDisappear)]) {
        [_page pageDidDisappear];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([_page respondsToSelector:@selector(preferredStatusBarStyle)]) {
        return [_page preferredStatusBarStyle];
    }
    return [super preferredStatusBarStyle];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super didRotateFromInterfaceOrientation:orientation];
    [[_collectionView collectionViewLayout] invalidateLayout];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_sectionControllers count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)index {
    id<LYSectionController> section = _sectionControllers[index];
    if ([section respondsToSelector:@selector(count)]) {
        return [section count];
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_sectionControllers[[indexPath section]] cellForItemAtIndex:[indexPath item]];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<LYSectionController> section = _sectionControllers[[indexPath section]];
    if ([section respondsToSelector:@selector(selectItemAtIndex:)]) {
        [section selectItemAtIndex:[indexPath item]];
    }
    // Deselect afterwards if we weren't pushed
    if ([[self navigationController] topViewController] == self) {
        [_collectionView LYDeselectAllItems];
    }
}

#pragma mark - LYCollectionViewDelegateLayout

- (id<LYCollectionViewBehavior>)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout behaviorForSectionAtIndex:(NSInteger)index {
    id<LYSectionController> section = _sectionControllers[index];
    return [section respondsToSelector:@selector(behavior)] ? [section behavior] : nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [[self view] frame].size;
    size.height -= [_collectionView scrollIndicatorInsets].top + [_collectionView scrollIndicatorInsets].bottom;
    return [_sectionControllers[[indexPath section]] sizeForItemAtIndex:[indexPath item] thatFits:size];
}

#pragma mark - LYPageDelegate

- (UIViewController *)parentViewControllerForPage:(id<LYPage>)page {
    return self;
}

- (void)pageDidUpdate:(id<LYPage>)page {
    if ([_page respondsToSelector:@selector(title)]) {
        [self setTitle:[_page title]];
    }
    if ([_page respondsToSelector:@selector(rightBarButtonItems)]) {
        [[self navigationItem] setRightBarButtonItems:[_page rightBarButtonItems]];
    }
    if ([_page respondsToSelector:@selector(leftBarButtonItems)]) {
        [[self navigationItem] setLeftBarButtonItems:[_page leftBarButtonItems]];
    }
    if ([_page respondsToSelector:@selector(titleView)]) {
        [[self navigationItem] setTitleView:[_page titleView]];
    }
    if ([_page respondsToSelector:@selector(hidesBackButton)]) {
        [[self navigationItem] setHidesBackButton:[_page hidesBackButton]];
    }
    if ([_page respondsToSelector:@selector(scrollEnabled)]) {
        [_collectionView setScrollEnabled:[_page scrollEnabled]];
    }
    _sections = [_page sections];
    [self _reloadSections];
}

#pragma mark - LYSectionDelegate

- (UIViewController *)parentViewControllerForSection:(id<LYSectionController>)section {
    return self;
}

- (UICollectionView *)collectionViewForSection:(id<LYSectionController>)section {
    return _collectionView;
}

- (void)section:(id<LYSectionController>)section reloadItemsAtIndexes:(NSIndexSet *)indexSet {
    NSInteger sectionIndex = [_sectionControllers indexOfObject:section];
    NSMutableArray *array = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [array addObject:[NSIndexPath indexPathForItem:idx inSection:sectionIndex]];
    }];
    [_collectionView reloadItemsAtIndexPaths:array];
}

- (void)section:(id<LYSectionController>)section registerClass:(Class)class forCellWithReuseIdentifier:(NSString *)reuseId {
    [_collectionView registerClass:class forCellWithReuseIdentifier:reuseId];
}

- (UICollectionViewCell *)section:(id<LYSectionController>)section dequeueReusableCellWithReuseIdentifier:(NSString *)reuseId forIndex:(NSInteger)index {
    return [_collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:[NSIndexPath indexPathForItem:index inSection:[_sectionControllers indexOfObject:section]]];
}

- (NSIndexSet *)visibleIndexesForSection:(id<LYSectionController>)section {
    return LYIndexPathsToIndexSet([_collectionView indexPathsForVisibleItems], [_sectionControllers indexOfObject:section]);
}

- (UICollectionViewCell *)section:(id<LYSectionController>)section cellForItemAtIndex:(NSInteger)index {
    return [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:[_sectionControllers indexOfObject:section]]];
}

- (UICollectionViewCell *)section:(id<LYSectionController>)section visibleCellForItemAtIndex:(NSInteger)index {
    NSIndexSet *visibleIndexes = [self visibleIndexesForSection:section];
    if ([visibleIndexes containsIndex:index]) {
        return [self section:section cellForItemAtIndex:index];
    }
    return nil;
}

#pragma mark - Internal

- (void)_reloadSections {
    [self view];
    
    NSMutableArray *sectionControllers = [NSMutableArray array];
    for (id<LYSection> i in _sections) {
        [sectionControllers addObject:[[[[i class] controllerClass] alloc] initWithSection:i]];
    }
    _sectionControllers = sectionControllers;
    for (NSInteger i = 0; i < [_sectionControllers count]; i++) {
        id<LYSectionController> controller = _sectionControllers[i];
        [controller setDelegate:self];
        [controller setup];
    }
    [_collectionView reloadData];
}

@end

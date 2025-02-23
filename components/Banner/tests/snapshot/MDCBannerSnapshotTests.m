// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MaterialSnapshot.h"

#import "MDCBannerView.h"
#import "MaterialButtons.h"
#import "MaterialTypographyScheme.h"

static NSString *const kBannerShortText = @"tristique senectus et";
static NSString *const kBannerLongText =
    @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.";
static const CGFloat kBannerContentPadding = 10.0f;

@interface MDCBannerViewSnapshotDynamicTypeContentSizeCategoryOverrideWindow : UIWindow

/** Used to override the value of @c preferredContentSizeCategory. */
@property(nonatomic, copy) UIContentSizeCategory contentSizeCategoryOverride;

@end

@implementation MDCBannerViewSnapshotDynamicTypeContentSizeCategoryOverrideWindow

- (instancetype)init {
  self = [super init];
  if (self) {
    self.contentSizeCategoryOverride = UIContentSizeCategoryLarge;
  }
  return self;
}

- (instancetype)initWithContentSizeCategoryOverride:
    (UIContentSizeCategory)contentSizeCategoryOverride {
  self = [super init];
  if (self) {
    self.contentSizeCategoryOverride = contentSizeCategoryOverride;
  }
  return self;
}

- (UITraitCollection *)traitCollection {
  if (@available(iOS 10.0, *)) {
    UITraitCollection *traitCollection = [UITraitCollection
        traitCollectionWithPreferredContentSizeCategory:self.contentSizeCategoryOverride];
    return traitCollection;
  }
  return [super traitCollection];
}

@end

/** Snapshot tests for MDCBannerView. */
@interface MDCBannerViewSnapshotTests : MDCSnapshotTestCase

/** The view being tested. */
@property(nonatomic, strong) MDCBannerView *bannerView;
@property(nonatomic, strong) MDCTypographyScheme *typographyScheme;

@end

@implementation MDCBannerViewSnapshotTests

- (void)setUp {
  [super setUp];

  // Uncomment below to recreate all the goldens (or add the following line to the specific
  // test you wish to recreate the golden for).
  // self.recordMode = YES;

  self.bannerView = [[MDCBannerView alloc] initWithFrame:CGRectZero];
  if (@available(iOS 11.0, *)) {
    NSDirectionalEdgeInsets directionalEdgeInsets = NSDirectionalEdgeInsetsZero;
    directionalEdgeInsets.leading = kBannerContentPadding;
    directionalEdgeInsets.trailing = kBannerContentPadding;
    self.bannerView.directionalLayoutMargins = directionalEdgeInsets;
  } else {
    UIEdgeInsets margins = UIEdgeInsetsZero;
    margins.left = kBannerContentPadding;
    margins.right = kBannerContentPadding;
    self.bannerView.layoutMargins = margins;
  }
}

- (void)tearDown {
  self.bannerView = nil;

  [super tearDown];
}

- (UIWindow *)generateWindowWithView:(UIView *)view
                 contentSizeCategory:(UIContentSizeCategory)sizeCategory
                              insets:(UIEdgeInsets)insets {
  MDCBannerViewSnapshotDynamicTypeContentSizeCategoryOverrideWindow *backgroundWindow =
      [[MDCBannerViewSnapshotDynamicTypeContentSizeCategoryOverrideWindow alloc]
          initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.bounds) + insets.left + insets.right,
                                   CGRectGetHeight(view.bounds) + insets.top + insets.bottom)];
  backgroundWindow.contentSizeCategoryOverride = sizeCategory;
  backgroundWindow.backgroundColor = [UIColor colorWithWhite:(CGFloat)0.8 alpha:1];
  [backgroundWindow addSubview:view];
  backgroundWindow.hidden = NO;

  CGRect frame = view.frame;
  frame.origin = CGPointMake(insets.left, insets.top);
  view.frame = frame;

  return backgroundWindow;
}

- (void)generateSnapshotAndVerifyForView:(UIView *)view {
  CGSize aSize = [view sizeThatFits:CGSizeMake(350, INFINITY)];
  view.frame = CGRectMake(0, 0, aSize.width, aSize.height);
  [view layoutIfNeeded];

  UIView *snapshotView = [view mdc_addToBackgroundView];
  [self snapshotVerifyView:snapshotView];
}

// TODO(https://github.com/material-components/material-components-ios/issues/7487):
// The size of the cell view sent for snapshot is not correct because Autolayout needs
// to be used as an environment.
- (void)generateSnapshotWithContentSizeCategoryAndNotificationPost:
            (UIContentSizeCategory)sizeCategory
                                                  andVerifyForView:(UIView *)view {
  CGSize aSize = [view sizeThatFits:CGSizeMake(350, INFINITY)];
  view.frame = CGRectMake(0, 0, aSize.width, aSize.height);
  [view layoutIfNeeded];

  UIWindow *snapshotWindow = [self generateWindowWithView:view
                                      contentSizeCategory:sizeCategory
                                                   insets:UIEdgeInsetsMake(10, 10, 10, 10)];
  [NSNotificationCenter.defaultCenter
      postNotificationName:UIContentSizeCategoryDidChangeNotification
                    object:nil];
  [self snapshotVerifyView:snapshotWindow];
}

- (void)changeViewToRTL:(UIView *)view {
  if (@available(iOS 9.0, *)) {
    view.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    for (UIView *subview in view.subviews) {
      [self changeViewToRTL:subview];
    }
  }
}

#pragma mark - Tests

- (void)testShortTextWithSingleActionLTR {
  // When
  self.bannerView.textLabel.text = kBannerShortText;
  MDCButton *button = self.bannerView.leadingButton;
  [button setTitle:@"Action" forState:UIControlStateNormal];
  button.uppercaseTitle = YES;
  [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  self.bannerView.imageView.hidden = YES;
  self.bannerView.trailingButton.hidden = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testShortTextWithSingleActionRTL {
  // When
  self.bannerView.textLabel.text = kBannerShortText;
  MDCButton *button = self.bannerView.leadingButton;
  [button setTitle:@"Action" forState:UIControlStateNormal];
  [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button.uppercaseTitle = YES;
  self.bannerView.trailingButton.hidden = YES;
  self.bannerView.imageView.hidden = YES;
  [self changeViewToRTL:self.bannerView];

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testLongTextWithSingleActionLTR {
  // When
  self.bannerView.textLabel.text = kBannerLongText;
  MDCButton *button = self.bannerView.leadingButton;
  [button setTitle:@"Action" forState:UIControlStateNormal];
  [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button.uppercaseTitle = YES;
  self.bannerView.trailingButton.hidden = YES;
  self.bannerView.imageView.hidden = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testLongTextWithSingleActionRTL {
  // When
  self.bannerView.textLabel.text = kBannerLongText;
  MDCButton *button = self.bannerView.leadingButton;
  [button setTitle:@"Action" forState:UIControlStateNormal];
  [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button.uppercaseTitle = YES;
  self.bannerView.trailingButton.hidden = YES;
  self.bannerView.imageView.hidden = YES;
  [self changeViewToRTL:self.bannerView];

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testLongTextWithTwoActionsLTR {
  // When
  self.bannerView.textLabel.text = kBannerLongText;
  MDCButton *button1 = self.bannerView.leadingButton;
  [button1 setTitle:@"Action1" forState:UIControlStateNormal];
  [button1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button1.uppercaseTitle = YES;
  MDCButton *button2 = self.bannerView.trailingButton;
  [button2 setTitle:@"Action2" forState:UIControlStateNormal];
  [button2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button2.uppercaseTitle = YES;
  self.bannerView.imageView.hidden = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testLongTextWithTwoActionsRTL {
  // When
  self.bannerView.textLabel.text = kBannerLongText;
  MDCButton *button1 = self.bannerView.leadingButton;
  [button1 setTitle:@"Action1" forState:UIControlStateNormal];
  [button1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button1.uppercaseTitle = YES;
  MDCButton *button2 = self.bannerView.trailingButton;
  [button2 setTitle:@"Action2" forState:UIControlStateNormal];
  [button2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button2.uppercaseTitle = YES;
  [self changeViewToRTL:self.bannerView];
  self.bannerView.imageView.hidden = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testSingleRowStyleLongTextWithSingleActionLTR {
  // When
  self.bannerView.textLabel.text = kBannerLongText;
  MDCButton *button1 = self.bannerView.leadingButton;
  [button1 setTitle:@"Action1" forState:UIControlStateNormal];
  [button1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button1.uppercaseTitle = YES;
  self.bannerView.bannerViewLayoutStyle = MDCBannerViewLayoutStyleSingleRow;
  self.bannerView.imageView.hidden = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testSingleRowStyleLongTextWithSingleActionRTL {
  // When
  self.bannerView.textLabel.text = kBannerLongText;
  MDCButton *button1 = self.bannerView.leadingButton;
  [button1 setTitle:@"Action1" forState:UIControlStateNormal];
  [button1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button1.uppercaseTitle = YES;
  self.bannerView.bannerViewLayoutStyle = MDCBannerViewLayoutStyleSingleRow;
  [self changeViewToRTL:self.bannerView];
  self.bannerView.imageView.hidden = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.bannerView];
}

- (void)testDynamicTypeForContentSizeCategoryExtraExtraLarge {
  if (@available(iOS 10.0, *)) {
    // Given
    self.bannerView = [[MDCBannerView alloc] init];
    self.typographyScheme =
        [[MDCTypographyScheme alloc] initWithDefaults:MDCTypographySchemeDefaultsMaterial201902];

    // When
    self.bannerView.textLabel.text = kBannerShortText;
    self.bannerView.textLabel.font = self.typographyScheme.body2;
    MDCButton *button = self.bannerView.leadingButton;
    [button setTitle:@"Action" forState:UIControlStateNormal];
    [button setTitleFont:self.typographyScheme.button forState:UIControlStateNormal];
    button.uppercaseTitle = YES;
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.bannerView.trailingButton.hidden = YES;
    self.bannerView.mdc_adjustsFontForContentSizeCategory = YES;

    // Then
    [self generateSnapshotWithContentSizeCategoryAndNotificationPost:
              UIContentSizeCategoryExtraExtraLarge
                                                    andVerifyForView:self.bannerView];
  }
}

- (void)testDynamicTypeForAttributedTextStringWhenContentSizeCategoryIsExtraExtraLarge {
  if (@available(iOS 10.0, *)) {
    // Given
    self.bannerView = [[MDCBannerView alloc] init];
    self.typographyScheme =
        [[MDCTypographyScheme alloc] initWithDefaults:MDCTypographySchemeDefaultsMaterial201902];
    MDCButton *button = self.bannerView.leadingButton;
    [button setTitle:@"Action" forState:UIControlStateNormal];
    [button setTitleFont:self.typographyScheme.button forState:UIControlStateNormal];
    button.uppercaseTitle = YES;
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.bannerView.trailingButton.hidden = YES;

    // When
    NSMutableAttributedString *bannerString =
        [[NSMutableAttributedString alloc] initWithString:kBannerShortText];
    [bannerString addAttribute:NSFontAttributeName
                         value:self.typographyScheme.body1
                         range:NSMakeRange(10, 8)];
    [bannerString addAttribute:NSForegroundColorAttributeName
                         value:UIColor.redColor
                         range:NSMakeRange(0, 9)];
    [bannerString addAttribute:NSLinkAttributeName
                         value:@"http://www.google.com"
                         range:NSMakeRange([kBannerShortText length] - 2, 2)];
    self.bannerView.textLabel.font = self.typographyScheme.body2;
    self.bannerView.textLabel.attributedText = bannerString;
    self.bannerView.mdc_adjustsFontForContentSizeCategory = YES;

    // Then
    [self generateSnapshotWithContentSizeCategoryAndNotificationPost:
              UIContentSizeCategoryExtraExtraLarge
                                                    andVerifyForView:self.bannerView];
  }
}

@end

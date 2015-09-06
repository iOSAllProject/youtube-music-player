//
//  UIViewController+LNPopupSupportPrivate.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <LNPopupController/UIViewController+LNPopupSupport.h>

@class LNPopupController;



void _LNPopupSupportFixInsetsForViewController(UIViewController* viewController, BOOL layout);

@interface _LNPopupBottomBarSupport : UIView @end

@interface UIViewController (LNPopupSupportPrivate)

- ( UIViewController*)_ln_common_childViewControllerForStatusBarStyle;

@property (nonatomic, strong, readonly, getter=_ln_popupController) LNPopupController* ln_popupController;
- (LNPopupController*)_ln_popupController_nocreate;
@property ( nonatomic, assign, readwrite) UIViewController* popupPresentationContainerViewController;
@property ( nonatomic, strong, readonly) UIViewController* popupContentViewController;

@property ( nonatomic, strong, readonly, getter=_ln_bottomBarSupport) _LNPopupBottomBarSupport* bottomBarSupport;

- ( UIView *)bottomDockingViewForPopup_nocreate;

@end

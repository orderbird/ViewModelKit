//
//  VMKTableViewRowActionViewModel.h
//  ViewModelKit
//
//  Created by Andre Trettin on 22/11/2016.
//  Copyright © 2016 Andre Trettin. All rights reserved.
//

@import UIKit;

#import "VMKAlertViewModelType.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VMKTableViewRowActionViewModelStyle) {
    VMKTableViewRowActionViewModelStyleDestructive,
    VMKTableViewRowActionViewModelStyleNormal
};

@class VMKTableViewRowActionViewModel;

@protocol VMKTableViewRowActionViewModelDelegate <NSObject>
- (nullable VMKViewModel *)tableViewRowActionViewModel:(VMKTableViewRowActionViewModel *)tableViewRowActionViewModel rowActionIndexPath:(NSIndexPath *)indexPath;

@optional
// Purpose of `indexPath` is to get a view to present a popover from.
// `UISwipeActionsConfiguration` handler provide a `sourceView`. So `indexPath` is not needed.
// Method above is preserved for backwards compatibility
- (nullable VMKViewModel *)tableViewRowActionViewModel:(VMKTableViewRowActionViewModel *)tableViewRowActionViewModel API_AVAILABLE(ios(13));

/**
 @discussion
`UISwipeActionsConfiguration` handler provide a `sourceView` which is an instance of `UISwipeActionStandardButton`
 and it's frame is shifted leftwards from the left edge of a tableview. Which results in corresponding offset  of the popover, if it's presented from that view.
 This method provides a control on which view is returned as sourceView for `presentControllerWithViewModel: inView:`
 @return YES to get UISwipeActionStandardButton.superview.superview,
 NO - to get unchanged `sourceView` from `UISwipeActionsConfiguration` handler
*/
- (BOOL)shouldOverrideSourceViewForSwipeAction API_AVAILABLE(ios(13));

@end

@interface VMKTableViewRowActionViewModel : VMKViewModel
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, assign, readonly) VMKTableViewRowActionViewModelStyle style;
@property (nonatomic, strong, readonly, nullable) UIColor *backgroundColor;
@property (nonatomic, weak) id<VMKTableViewRowActionViewModelDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithModel:(nullable id)model NS_UNAVAILABLE;
- (instancetype)initWithTitle:(nullable NSString *)title style:(VMKTableViewRowActionViewModelStyle)style backgroundColor:(nullable UIColor *)backgroundColor delegate:(nullable id<VMKTableViewRowActionViewModelDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (nullable VMKViewModel *)swipedRowActionAtIndexPath:(NSIndexPath *)indexPath;

- (nullable VMKViewModel *)swipedRowAction API_AVAILABLE(ios(13));;

@end

NS_ASSUME_NONNULL_END

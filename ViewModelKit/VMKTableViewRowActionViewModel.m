//
//  VMKTableViewRowActionViewModel.m
//  ViewModelKit
//
//  Created by Andre Trettin on 22/11/2016.
//  Copyright © 2016 Andre Trettin. All rights reserved.
//

#import "VMKTableViewRowActionViewModel.h"

@interface VMKTableViewRowActionViewModel ()
@property (nonatomic, copy, readwrite, nullable) NSString *title;
@property (nonatomic, assign, readwrite) VMKTableViewRowActionViewModelStyle style;
@property (nonatomic, strong, readwrite, nullable) UIColor *backgroundColor;
@end

@implementation VMKTableViewRowActionViewModel

- (instancetype)initWithTitle:(nullable NSString *)title style:(VMKTableViewRowActionViewModelStyle)style backgroundColor:(nullable UIColor *)backgroundColor delegate:(nullable id<VMKTableViewRowActionViewModelDelegate>)delegate {
    self = [super initWithModel:nil];
    if (self) {
        _title = title;
        _style = style;
        _backgroundColor = backgroundColor;
        _delegate = delegate;
    }
    return self;
}

- (nullable VMKViewModel *)swipedRowActionAtIndexPath:(NSIndexPath *)indexPath {
    // in fact the action is executed, not just view model veing returned
    // if nil is returned, removal had happened
    // else, if instance of viewModel returned, positions were just vioded, so no removal
    return [self.delegate tableViewRowActionViewModel:self rowActionIndexPath:indexPath];
}

- (nullable VMKViewModel *)swipedRowAction {
    return [self.delegate tableViewRowActionViewModel:self];
    //TODO: pos should implement this method also
    // search for `rowActionIndexPath` in PRO
}

@end

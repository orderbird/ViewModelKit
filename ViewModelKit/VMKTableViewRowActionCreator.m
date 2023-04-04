//
//  VMKTableViewRowActionCreator.m
//  ViewModelKit
//
//  Created by Andre Trettin on 22/11/2016.
//  Copyright © 2016 Andre Trettin. All rights reserved.
//

#import "VMKTableViewRowActionCreator+Private.h"
#import "VMKTableViewDataSource.h"

@implementation VMKTableViewRowActionCreator

- (instancetype)initWithTableView:(UITableView *)tableView rowActionsType:(id<VMKTableViewRowActionsType>)rowActionsType {
    
    self = [super init];
    if (self) {
        _tableView = tableView;
        _rowActionsType = rowActionsType;
    }
    return self;
}

#pragma mark - UISwipeActionsConfiguration

- (nullable UISwipeActionsConfiguration *)swipeActionsConfiguration {
    Class swipeContainer = NSClassFromString(@"_UITableViewCellSwipeContainerView");
    NSMutableArray<UIContextualAction *> * actions = [NSMutableArray array];
    for (VMKTableViewRowActionViewModel *rowAction in self.rowActionsType.rowActions) {
        UIContextualAction *tableViewAction = [UIContextualAction contextualActionWithStyle: rowAction.contextualActionStyle
                                                                                      title: rowAction.title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            VMKViewModel *viewModel = [rowAction swipedRowAction];
            BOOL isRowModified = NO;
            if (viewModel) {
                // positions were voided
                VMKTableViewDataSource *tableViewDataSource = self.tableView.dataSource;
                BOOL shouldOverrideSourceViewForSwipeAction = [rowAction.delegate shouldOverrideSourceViewForSwipeAction];
                UIView * cellView = [self getSuperViewOfClass: swipeContainer fromView: sourceView];
                //UIView * cellView = sourceView.superview.superview;
                UIView * viewToSend = shouldOverrideSourceViewForSwipeAction ? cellView : sourceView;
                [tableViewDataSource requestViewWithViewModel:viewModel fromView: viewToSend];
                // view model is returned => it's actually an alert view model
            } else {
                // positions were removed
                isRowModified = YES;
            }
            completionHandler(isRowModified);
        }];
        
        tableViewAction.backgroundColor = rowAction.backgroundColor;
        [actions addObject: tableViewAction];
    }
    
    UISwipeActionsConfiguration * config = [UISwipeActionsConfiguration configurationWithActions: actions];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

#pragma mark - UITableViewRowAction API
- (nullable NSArray<UITableViewRowAction *> *)tableViewRowActions {
    NSMutableArray *tableViewActions = [[NSMutableArray alloc] initWithCapacity:self.rowActionsType.rowActions.count];
    for (VMKTableViewRowActionViewModel *rowAction in self.rowActionsType.rowActions) {
        UITableViewRowAction *tableViewAction = [UITableViewRowAction rowActionWithStyle:rowAction.tableViewRowActionStyle
                                                                                   title:rowAction.title
                                                                                 handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    
            // the self must be a strong pointer because the creator object is released after creating the objects.
            // but we need the handler to be called.
            [self handleRowAction:rowAction atIndexPath:indexPath];
        }];
        tableViewAction.backgroundColor = rowAction.backgroundColor;
        [tableViewActions addObject:tableViewAction];
    }
    return tableViewActions;
}

- (void)handleRowAction:(VMKTableViewRowActionViewModel *)rowAction atIndexPath:(NSIndexPath *)indexPath {
    
    VMKViewModel *viewModel = [rowAction swipedRowActionAtIndexPath:indexPath];
    [self.tableView setEditing:NO animated:YES];
    if (viewModel) {
        VMKTableViewDataSource *tableViewDataSource = self.tableView.dataSource;
        [tableViewDataSource requestViewWithViewModel:viewModel atIndexPath:indexPath];
    }
}

#pragma mark - helper

- (UIView *)getSuperViewOfClass:(Class)aClass fromView:(UIView *)view {
    UIView * result = view;
    NSLog(@"cell from %@", view);
    int i = 0;
    while (result && [result isKindOfClass: aClass] == NO) {
        result = result.superview;
        NSLog(@"---- %d %@", i, result);
        i++;
    }
    NSLog(@"cell from return %@", result);
    return result;
}

@end

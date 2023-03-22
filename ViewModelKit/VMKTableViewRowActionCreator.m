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
    
    NSMutableArray<UIContextualAction *> * actions = [NSMutableArray array];
    
    for (VMKTableViewRowActionViewModel *rowAction in self.rowActionsType.rowActions) {
        
        UIContextualActionStyle style = [self contextualActionStyleFromRowActionViewModel: rowAction];
        
        UIContextualAction *tableViewAction = [UIContextualAction contextualActionWithStyle: style
                                                                                      title: rowAction.title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            //[self handleContextualRowAction: rowAction atIndexPath: indexPath];
            VMKViewModel *viewModel = [rowAction swipedRowAction];
            if (viewModel) {
                // positions were voided
                VMKTableViewDataSource *tableViewDataSource = self.tableView.dataSource;
                [tableViewDataSource requestViewWithViewModel:viewModel fromView: sourceView];
                // view model is returned => it's actually an alert view model
                completionHandler(NO);
            } else {
                // positions were removed
                completionHandler(YES);
            }
        }];
        
        tableViewAction.backgroundColor = rowAction.backgroundColor;
        [actions addObject: tableViewAction];
    }
    
    UISwipeActionsConfiguration * config = [UISwipeActionsConfiguration configurationWithActions: actions];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

- (UIContextualActionStyle)contextualActionStyleFromRowActionViewModel:(VMKTableViewRowActionViewModel *)rowActionViewModel {
    if (rowActionViewModel.style == VMKTableViewRowActionViewModelStyleDestructive) {
        return UIContextualActionStyleDestructive;
    }
    return UIContextualActionStyleNormal;

}


#pragma mark - UITableViewRowAction API
- (nullable NSArray<UITableViewRowAction *> *)tableViewRowActions {
    
    NSMutableArray *tableViewActions = [[NSMutableArray alloc] initWithCapacity:self.rowActionsType.rowActions.count];
    for (VMKTableViewRowActionViewModel *rowAction in self.rowActionsType.rowActions) {
        
        UITableViewRowActionStyle style = [self styleFromRowActionViewModel:rowAction];
        UITableViewRowAction *tableViewAction = [UITableViewRowAction rowActionWithStyle:style title:rowAction.title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    
            // the self must be a strong pointer because the creator object is released after creating the objects.
            // but we need the handler to be called.
            [self handleRowAction:rowAction atIndexPath:indexPath];
        }];
        tableViewAction.backgroundColor = rowAction.backgroundColor;
        [tableViewActions addObject:tableViewAction];
    }
    return tableViewActions;
}

- (UITableViewRowActionStyle)styleFromRowActionViewModel:(VMKTableViewRowActionViewModel *)rowActionViewModel {
    
    if (rowActionViewModel.style == VMKTableViewRowActionViewModelStyleDestructive) {
        return UITableViewRowActionStyleDestructive;
    }
    
    return UITableViewRowActionStyleNormal;
}

- (void)handleRowAction:(VMKTableViewRowActionViewModel *)rowAction atIndexPath:(NSIndexPath *)indexPath {
    
    VMKViewModel *viewModel = [rowAction swipedRowActionAtIndexPath:indexPath];
    [self.tableView setEditing:NO animated:YES];
    if (viewModel) {
        VMKTableViewDataSource *tableViewDataSource = self.tableView.dataSource;
        [tableViewDataSource requestViewWithViewModel:viewModel atIndexPath:indexPath];
    }
}

@end

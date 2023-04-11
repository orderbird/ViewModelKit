//
//  VMKTableViewDataSourceDelegate.h
//  ViewModelKit
//
//  Created by Andre Trettin on 04.01.16.
//  Copyright © 2016 Andre Trettin. All rights reserved.
//

@import UIKit;

#import "VMKCellType.h"
#import "VMKHeaderFooterType.h"

@class VMKTableViewDataSource;
@class VMKChangeSet;

NS_ASSUME_NONNULL_BEGIN

@protocol VMKTableViewDataSourceDelegate <NSObject>
- (NSString *)dataSource:(VMKTableViewDataSource *)dataSource cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;
- (void)dataSource:(VMKTableViewDataSource *)dataSource configureCell:(UITableViewCell *)cell withViewModel:(__kindof VMKViewModel<VMKCellType> *)viewModel;

- (void)dataSource:(VMKTableViewDataSource *)dataSource didChangeWithChangeSet:(VMKChangeSet *)changeSet;

- (void)requestViewWithViewModel:(VMKViewModel *)viewModel atIndexPath:(NSIndexPath *)indexPath;

@optional
- (nullable NSString *)dataSource:(VMKTableViewDataSource *)dataSource titleForHeaderInSection:(NSInteger)section;
- (nullable NSString *)dataSource:(VMKTableViewDataSource *)dataSource titleForFooterInSection:(NSInteger)section;

// section headers with cells
- (NSString *)dataSource:(VMKTableViewDataSource *)dataSource headerViewIdentifierAtSection:(NSInteger)section;

- (void)dataSource:(VMKTableViewDataSource *)dataSource configureHeaderView:(UITableViewHeaderFooterView *)cell withViewModel:(VMKViewModel<VMKHeaderFooterType> *)viewModel;

- (void)requestViewWithViewModel:(VMKViewModel *)viewModel fromView:(UIView *)sourceView API_AVAILABLE(ios(13));
@end

NS_ASSUME_NONNULL_END

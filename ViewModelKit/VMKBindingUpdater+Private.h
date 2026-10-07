//
//  VMKBindingUpdater+Private.h
//  ViewModelKit
//
//  Created by Andre Trettin on 21/11/2016.
//  Copyright © 2016 Andre Trettin. All rights reserved.
//

#import "VMKBindingUpdater.h"

NS_ASSUME_NONNULL_BEGIN

@interface VMKBindingUpdater ()
@property (nonatomic, strong, readwrite, nullable) NSDictionary<NSKeyValueChangeKey, id> *change;

@property (weak, nonatomic) id observer;
/// The observer's address, for identity comparison only - never dereferenced. Unlike `observer`,
/// it survives the observer's deallocation (weak references are zeroed before -dealloc runs), so
/// an observer can still unbind itself from its own -dealloc.
@property (assign, nonatomic) const void *observerIdentity;
@property (assign, nonatomic) SEL updateAction;
@property (assign, nonatomic) BOOL updateActionsTakesBindingUpdaterParam;
@end

NS_ASSUME_NONNULL_END

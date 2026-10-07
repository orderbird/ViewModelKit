//
//  VMKObservableManagerTests.m
//  ViewModelKit
//
//  Created by Andre Trettin on 26/07/16.
//  Copyright © 2016 Andre Trettin. All rights reserved.
//

@import XCTest;
@import OCHamcrest;
@import OCMockito;

#import "VMKObservableManager.h"
#import "VMKObservableManager+Private.h"
#import "VMKObservable+Private.h"
#import "VMKBindingUpdater.h"
#import "FakeObject.h"

@interface FakeUnbindingInDeallocObserver : FakeObject
@property (nonatomic, weak) VMKObservableManager *manager;
@property (nonatomic, copy) NSString *keyPath;
@end

@implementation FakeUnbindingInDeallocObserver

- (void)dealloc {
    if (_keyPath) {
        [_manager removeBindingObserver:self forKeyPath:_keyPath];
    } else {
        [_manager removeBindingObserver:self];
    }
}

@end

@interface VMKObservableManagerTests : XCTestCase
@property (nonatomic, strong) VMKObservableManager *sut;
@property (nonatomic, strong) FakeObject *fakeObject;
@property (nonatomic, strong) FakeObject *fakeObject2;
@property (nonatomic, strong) FakeObject *fakeObject3;
@property (nonatomic, strong) VMKBindingUpdater *bindingUpdater;
@property (nonatomic, strong) VMKBindingUpdater *bindingUpdater2;
@property (nonatomic, strong) VMKBindingUpdater *bindingUpdater3;
@end

@implementation VMKObservableManagerTests

- (void)setUp {
    [super setUp];
    self.sut = [[VMKObservableManager alloc] init];
    self.fakeObject = [[FakeObject alloc] init];
    self.fakeObject2 = [[FakeObject alloc] init];
    self.fakeObject3 = [[FakeObject alloc] init];
    self.bindingUpdater = [[VMKBindingUpdater alloc] initWithObserver:self.fakeObject updateAction:@selector(someAction)];
    self.bindingUpdater2 = [[VMKBindingUpdater alloc] initWithObserver:self.fakeObject2 updateAction:@selector(someAction)];
    self.bindingUpdater3 = [[VMKBindingUpdater alloc] initWithObserver:self.fakeObject3 updateAction:@selector(someAction)];
}

- (void)tearDown {
    self.fakeObject = nil;
    self.fakeObject2 = nil;
    self.fakeObject3 = nil;
    self.bindingUpdater = nil;
    self.bindingUpdater2 = nil;
    self.bindingUpdater3 = nil;
    self.sut = nil;
    [super tearDown];
}

#pragma mark - helper

- (void)addObjectsToSut {
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty)) bindingUpdater:self.bindingUpdater];
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty2)) bindingUpdater:self.bindingUpdater];
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty3)) bindingUpdater:self.bindingUpdater];
    
    [self.sut addObject:self.fakeObject2 forKeyPath:NSStringFromSelector(@selector(observableProperty)) bindingUpdater:self.bindingUpdater2];
    [self.sut addObject:self.fakeObject2 forKeyPath:NSStringFromSelector(@selector(observableProperty2)) bindingUpdater:self.bindingUpdater2];
    
    [self.sut addObject:self.fakeObject3 forKeyPath:NSStringFromSelector(@selector(observableProperty3)) bindingUpdater:self.bindingUpdater3];
}

- (void)addObservableWithDeallocatedObserverForObject:(id)object keyPath:(NSString *)keyPath {
    @autoreleasepool {
        FakeObject *observer = [[FakeObject alloc] init];
        VMKBindingUpdater *bindingUpdater = [[VMKBindingUpdater alloc] initWithObserver:observer updateAction:@selector(someAction)];
        [self.sut addObject:object forKeyPath:keyPath bindingUpdater:bindingUpdater];
    }
}

- (NSArray<VMKBindingUpdater *> *)bindingUpdatersForKeyPath:(NSString *)keyPath {
    NSMutableArray<VMKBindingUpdater *> *bindingUpdaters = [[NSMutableArray alloc] init];
    for (VMKObservable *observable in self.sut.observables) {
        if ([observable isKeyPath:keyPath]) {
            [bindingUpdaters addObject:observable.bindingUpdater];
        }
    }
    return bindingUpdaters;
}

#pragma mark - init

- (void)testSutIsNotNil {
    assertThat(self.sut, notNilValue());
}

- (void)testSutObservablesIsNotNil {
    assertThat(self.sut.observables, notNilValue());
}

- (void)testSutObservablesIsEmpty {
    assertThat(self.sut.observables, hasCountOf(0));
}

#pragma mark - addObject:forKeyPath:bindingUpdater:

- (void)testAddObjectForKeyPathBindingUpdaterAddsAnObservaleWithValidValues {
    
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty)) bindingUpdater:self.bindingUpdater];
    
    assertThat(self.sut.observables, hasCountOf(1));
}

- (void)testAddObjectForKeyPathBindingUpdaterAddsTwoObservaleIfCalledTwice {
    
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty)) bindingUpdater:self.bindingUpdater];
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty2)) bindingUpdater:self.bindingUpdater];
    
    assertThat(self.sut.observables, hasCountOf(2));
}

- (void)testAddObjectForKeyPathBindingUpdaterTwiceWillThrow {
    
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty)) bindingUpdater:self.bindingUpdater];
    
    XCTAssertThrows([self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty)) bindingUpdater:self.bindingUpdater]);
}

- (void)testAddObjectForKeyPathBindingUpdaterAddsSixObservales {
    
    [self addObjectsToSut];
    
    assertThat(self.sut.observables, hasCountOf(6));
}

#pragma mark - addObject:withBindings:

- (void)testAddObjectWithEmptyBindingsAddsNothing {
    
    VMKBindingDictionary *testDic = @{};
    
    [self.sut addObject:self.fakeObject withBindings:testDic];
    
    assertThat(self.sut.observables, hasCountOf(0));
}

- (void)testAddObjectWithBindingsAddsTheBindingAsObservable {
    
    VMKBindingDictionary *testDic = @{ NSStringFromSelector(@selector(observableProperty)): self.bindingUpdater };
    
    [self.sut addObject:self.fakeObject withBindings:testDic];
    
    assertThat(self.sut.observables, hasCountOf(1));
}

#pragma mark - removeBindingObserver:ForKeyPath:

- (void)testRemoveBindingObserverForKeyPathRemovesNothingIfObjectIsNotObserved {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self forKeyPath:NSStringFromSelector(@selector(observableProperty2))];
    
    assertThat(self.sut.observables, hasCountOf(6));
}

- (void)testRemoveBindingObserverForKeyPathRemovesOneObservable {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty2))];
    
    assertThat(self.sut.observables, hasCountOf(5));
}

- (void)testRemoveBindingObserverForKeyPathRemovesOnlyOneObservableIfCalledTwice {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty2))];
    [self.sut removeBindingObserver:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty2))];
    
    assertThat(self.sut.observables, hasCountOf(5));
}

- (void)testRemoveBindingObserverForKeyPathRemovesTwoObservableForTwoDifferentObjects {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty))];
    [self.sut removeBindingObserver:self.fakeObject2 forKeyPath:NSStringFromSelector(@selector(observableProperty2))];
    
    assertThat(self.sut.observables, hasCountOf(4));
}

#pragma mark - removeBindingObserver:

- (void)testRemoveBindingObserverRemovesNothingIfObjectIsNotObserved {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self];
    
    assertThat(self.sut.observables, hasCountOf(6));
}

- (void)testRemoveBindingObserverRemovesThreeObservables {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self.fakeObject];
    
    assertThat(self.sut.observables, hasCountOf(3));
}

- (void)testRemoveBindingObserverRemovesTwoObservables {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self.fakeObject2];
    
    assertThat(self.sut.observables, hasCountOf(4));
}

- (void)testRemoveBindingObserverRemovesOneObservables {
    [self addObjectsToSut];
    
    [self.sut removeBindingObserver:self.fakeObject3];
    
    assertThat(self.sut.observables, hasCountOf(5));
}

#pragma mark - deallocated observers

- (void)testRemoveBindingObserverCalledFromObserversDeallocRemovesItsObservable {
    [self addObjectsToSut];
    @autoreleasepool {
        FakeUnbindingInDeallocObserver *observer = [[FakeUnbindingInDeallocObserver alloc] init];
        observer.manager = self.sut;
        VMKBindingUpdater *bindingUpdater = [[VMKBindingUpdater alloc] initWithObserver:observer updateAction:@selector(someAction)];
        [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableArray)) bindingUpdater:bindingUpdater];
    }
    
    assertThat(self.sut.observables, hasCountOf(6));
}

- (void)testRemoveBindingObserverAlsoRemovesObservablesOfDeallocatedObservers {
    [self addObjectsToSut];
    [self addObservableWithDeallocatedObserverForObject:self.fakeObject keyPath:NSStringFromSelector(@selector(observableArray))];
    
    [self.sut removeBindingObserver:self.fakeObject3];
    
    assertThat(self.sut.observables, hasCountOf(5));
}

- (void)testRemoveBindingObserverForKeyPathCalledFromObserversDeallocRemovesOnlyItsBindingForThatKeyPath {
    NSString *sharedKeyPath = NSStringFromSelector(@selector(observableArray));
    NSString *otherKeyPath = NSStringFromSelector(@selector(observableProperty));
    [self.sut addObject:self.fakeObject forKeyPath:sharedKeyPath bindingUpdater:self.bindingUpdater2];
    VMKBindingUpdater *otherKeyPathBindingUpdater;
    @autoreleasepool {
        FakeUnbindingInDeallocObserver *observer = [[FakeUnbindingInDeallocObserver alloc] init];
        observer.manager = self.sut;
        observer.keyPath = sharedKeyPath;
        VMKBindingUpdater *sharedKeyPathBindingUpdater = [[VMKBindingUpdater alloc] initWithObserver:observer updateAction:@selector(someAction)];
        otherKeyPathBindingUpdater = [[VMKBindingUpdater alloc] initWithObserver:observer updateAction:@selector(someAction)];
        [self.sut addObject:self.fakeObject forKeyPath:sharedKeyPath bindingUpdater:sharedKeyPathBindingUpdater];
        [self.sut addObject:self.fakeObject forKeyPath:otherKeyPath bindingUpdater:otherKeyPathBindingUpdater];
    }

    assertThat([self bindingUpdatersForKeyPath:sharedKeyPath], containsIn(@[self.bindingUpdater2]));
    assertThat([self bindingUpdatersForKeyPath:otherKeyPath], containsIn(@[otherKeyPathBindingUpdater]));
}

#pragma mark - removeObserverForObject

- (void)testRemoveObserverForObjectRemovesOnlyOneObject {
    [self addObjectsToSut];
    
    [self.sut removeObserverForObject:self.fakeObject3];
    
    assertThat(self.sut.observables, hasCountOf(5));
}

#pragma mark - removeAllBindings

- (void)testRemoveAllBindingsRemovesAll {
    [self addObjectsToSut];

    [self.sut removeAllBindings];

    assertThat(self.sut.observables, hasCountOf(0));
}

#pragma mark - removeAllObserverForKeyPath:

- (void)testRemoveAllObserverForKeyPathRemovesNothingIfKeyPathIsNotObserved {
    [self addObjectsToSut];
    
    [self.sut removeAllObserverForKeyPath:@"keyPathNotObserved"];
    
    assertThat(self.sut.observables, hasCountOf(6));
}

- (void)testRemoveAllObserverForKeyPathRemovesKeyPathObservableProperty {
    [self addObjectsToSut];
    
    [self.sut removeAllObserverForKeyPath:NSStringFromSelector(@selector(observableProperty))];
    
    assertThat(self.sut.observables, hasCountOf(4));
}

- (void)testRemoveAllObserverForKeyPathRemovesKeyPath {
    [self addObjectsToSut];
    
    [self.sut removeAllObserverForKeyPath:NSStringFromSelector(@selector(observableProperty2))];
    
    assertThat(self.sut.observables, hasCountOf(4));
}

#pragma mark - description

- (void)testDescriptionContainsObservableManager {
    assertThat(self.sut.description, containsSubstring(@"VMKObservableManager"));
}

- (void)testDescriptionContainsZeroObservables {
    assertThat(self.sut.description, containsSubstring(@"0 observables"));
}

- (void)testDescriptionContainsOneObservables {
    [self.sut addObject:self.fakeObject forKeyPath:NSStringFromSelector(@selector(observableProperty)) bindingUpdater:self.bindingUpdater];

    assertThat(self.sut.description, containsSubstring(@"1 observables"));
}

@end

//
//  NSNotificationCenterRACSupportSpec.m
//  ReactiveObjC
//
//  Created by Justin Spahr-Summers on 2012-12-07.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

@import Quick;
@import Nimble;

#import "NSNotificationCenter+RACSupport.h"
#import "RACSignal.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "NSObject+RACDeallocating.h"

static NSString * const TestNotification = @"TestNotification";

QuickSpecBegin(NSNotificationCenterRACSupportSpec)

__block NSNotificationCenter *notificationCenter;

beforeEach(^{
	// The compiler gets confused and thinks you might be messaging
	// NSDistributedNotificationCenter otherwise. Wtf?
	notificationCenter = NSNotificationCenter.defaultCenter;
});

it(@"should send the notification when posted by any object", ^{
	RACSignal *signal = [notificationCenter rac_addObserverForName:TestNotification object:nil];

	__block NSUInteger count = 0;
	[signal subscribeNext:^(NSNotification *notification) {
		++count;

		expect(notification).to(beAKindOf(NSNotification.class));
		expect(notification.name).to(equal(TestNotification));
	}];

	expect(@(count)).to(equal(@0));

	[notificationCenter postNotificationName:TestNotification object:nil];
	expect(@(count)).to(equal(@1));

	[notificationCenter postNotificationName:TestNotification object:self];
	expect(@(count)).to(equal(@2));
});

it(@"should send the notification when posted by a specific object", ^{
	RACSignal *signal = [notificationCenter rac_addObserverForName:TestNotification object:self];

	__block NSUInteger count = 0;
	[signal subscribeNext:^(NSNotification *notification) {
		++count;

		expect(notification).to(beAKindOf(NSNotification.class));
		expect(notification.name).to(equal(TestNotification));
		expect(notification.object).to(beIdenticalTo(self));
	}];

	expect(@(count)).to(equal(@0));

	[notificationCenter postNotificationName:TestNotification object:nil];
	expect(@(count)).to(equal(@0));

	[notificationCenter postNotificationName:TestNotification object:self];
	expect(@(count)).to(equal(@1));
});

it(@"shouldn't strongly capture the notification object", ^{
	RACSignal *signal __attribute__((objc_precise_lifetime, unused));

	__block BOOL dealloced = NO;
	@autoreleasepool {
		NSObject *notificationObject = [[NSObject alloc] init];
		[notificationObject.rac_deallocDisposable addDisposable:[RACDisposable disposableWithBlock:^{
			dealloced = YES;
		}]];

		signal = [notificationCenter rac_addObserverForName:TestNotification object:notificationObject];
	}

	expect(@(dealloced)).to(beTruthy());
});

QuickSpecEnd

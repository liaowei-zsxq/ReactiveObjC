//
//  RACSubscriberSpec.m
//  ReactiveObjC
//
//  Created by Justin Spahr-Summers on 2012-11-27.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

@import Quick;
@import Nimble;

#import "RACSubscriberExamples.h"

#import "RACSubscriber.h"
#import "RACSubscriber+Private.h"
#import <stdatomic.h>

QuickSpecBegin(RACSubscriberSpec)

__block RACSubscriber *subscriber;
__block NSMutableArray *values;

__block _Atomic(BOOL) finished;
__block atomic_int nextsAfterFinished;

__block BOOL success;
__block NSError *error;

beforeEach(^{
	values = [NSMutableArray array];

	finished = NO;
	nextsAfterFinished = 0;

	success = YES;
	error = nil;

	subscriber = [RACSubscriber subscriberWithNext:^(id value) {
		if (finished) atomic_fetch_add(&nextsAfterFinished, 1);

		[values addObject:value];
	} error:^(NSError *e) {
		error = e;
		success = NO;
	} completed:^{
		success = YES;
	}];
});

itBehavesLike(RACSubscriberExamples, ^{
	return @{
		RACSubscriberExampleSubscriber: subscriber,
		RACSubscriberExampleValuesReceivedBlock: [^{ return [values copy]; } copy],
		RACSubscriberExampleErrorReceivedBlock: [^{ return error; } copy],
		RACSubscriberExampleSuccessBlock: [^{ return success; } copy]
	};
});

describe(@"finishing", ^{
	__block void (^sendValues)(void);
	__block BOOL expectedSuccess;

	__block dispatch_group_t dispatchGroup;
	__block dispatch_queue_t concurrentQueue;

	beforeEach(^{
		dispatchGroup = dispatch_group_create();
		expect(dispatchGroup).notTo(beNil());

		concurrentQueue = dispatch_queue_create("org.reactivecocoa.ReactiveObjC.RACSubscriberSpec", DISPATCH_QUEUE_CONCURRENT);
		expect(concurrentQueue).notTo(beNil());

		dispatch_suspend(concurrentQueue);

		sendValues = [^{
			for (NSUInteger i = 0; i < 15; i++) {
				dispatch_group_async(dispatchGroup, concurrentQueue, ^{
					[subscriber sendNext:@(i)];
				});
			}
		} copy];

		sendValues();
	});

	afterEach(^{
		sendValues();
		dispatch_resume(concurrentQueue);

		// Time out after one second.
		dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
		expect(@(dispatch_group_wait(dispatchGroup, time))).to(equal(@0));

		dispatchGroup = NULL;
		concurrentQueue = NULL;

		expect(@(nextsAfterFinished)).to(equal(@0));

		if (expectedSuccess) {
			expect(@(success)).to(beTruthy());
			expect(error).to(beNil());
		} else {
			expect(@(success)).to(beFalsy());
		}
	});

	it(@"should never invoke next after sending completed", ^{
		expectedSuccess = YES;

		dispatch_group_async(dispatchGroup, concurrentQueue, ^{
			[subscriber sendCompleted];

			finished = YES;
			atomic_thread_fence(memory_order_seq_cst);
		});
	});

	it(@"should never invoke next after sending error", ^{
		expectedSuccess = NO;

		dispatch_group_async(dispatchGroup, concurrentQueue, ^{
			[subscriber sendError:nil];

			finished = YES;
			atomic_thread_fence(memory_order_seq_cst);
		});
	});
});

QuickSpecEnd

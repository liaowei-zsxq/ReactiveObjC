//
//  RACControlCommandExamples.m
//  ReactiveObjC
//
//  Created by Justin Spahr-Summers on 2013-08-15.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

@import Quick;
@import Nimble;

#import "RACControlCommandExamples.h"

#import "RACCommand.h"
#import "RACSubject.h"
#import "RACUnit.h"

NSString * const RACControlCommandExamples = @"RACControlCommandExamples";
NSString * const RACControlCommandExampleControl = @"RACControlCommandExampleControl";
NSString * const RACControlCommandExampleActivateBlock = @"RACControlCommandExampleActivateBlock";

// Methods used by the unit test that would otherwise require platform-specific
// imports.
@interface NSObject (RACControlCommandExamples)

@property (nonatomic, strong) RACCommand *rac_command;

- (BOOL)isEnabled;

@end

QuickConfigurationBegin(RACControlCommandExampleGroups)

+ (void)configure:(Configuration *)configuration {
	sharedExamples(RACControlCommandExamples, ^(QCKDSLSharedExampleContext exampleContext) {
		__block id control;
		__block void (^activate)(id);

		__block RACSubject *enabledSubject;
		__block RACCommand *command;

		beforeEach(^{
			control = exampleContext()[RACControlCommandExampleControl];
			activate = [exampleContext()[RACControlCommandExampleActivateBlock] copy];

			enabledSubject = [RACSubject subject];
			command = [[RACCommand alloc] initWithEnabled:enabledSubject signalBlock:^(id sender) {
				return [RACSignal return:sender];
			}];

			[control setRac_command:command];
		});

		it(@"should bind the control's enabledness to the command", ^{
			expect(@([control isEnabled])).toEventually(beTruthy());

			[enabledSubject sendNext:@NO];
			expect(@([control isEnabled])).toEventually(beFalsy());

			[enabledSubject sendNext:@YES];
			expect(@([control isEnabled])).toEventually(beTruthy());
		});

		it(@"should execute the control's command when activated", ^{
			__block BOOL executed = NO;
			[[command.executionSignals flatten] subscribeNext:^(id sender) {
				expect(sender).to(equal(control));
				executed = YES;
			}];

			activate(control);
			expect(@(executed)).toEventually(beTruthy());
		});

		it(@"should overwrite an existing command when setting a new one", ^{
			RACCommand *secondCommand = [[RACCommand alloc] initWithSignalBlock:^(id _) {
				return [RACSignal return:RACUnit.defaultUnit];
			}];

			[control setRac_command:secondCommand];
			expect([control rac_command]).to(beIdenticalTo(secondCommand));
		});
	});
}

QuickConfigurationEnd

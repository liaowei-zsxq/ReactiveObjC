//
//  UIButtonRACSupportSpec.m
//  ReactiveObjC
//
//  Created by Ash Furrow on 2013-06-06.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

@import Quick;
@import Nimble;

#import "RACControlCommandExamples.h"
#import "RACTestUIButton.h"

#import "UIButton+RACCommandSupport.h"
#import "RACCommand.h"
#import "RACDisposable.h"

QuickSpecBegin(UIButtonRACSupportSpec)

describe(@"UIButton", ^{
	__block UIButton *button;
	
	beforeEach(^{
		button = [RACTestUIButton button];
		expect(button).notTo(beNil());
	});

	itBehavesLike(RACControlCommandExamples, ^{
		return @{
			RACControlCommandExampleControl: button,
			RACControlCommandExampleActivateBlock: ^(UIButton *button) {
				#pragma clang diagnostic push
				#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[button sendActionsForControlEvents:UIControlEventTouchUpInside];
				#pragma clang diagnostic pop
			}
		};
	});
});

QuickSpecEnd

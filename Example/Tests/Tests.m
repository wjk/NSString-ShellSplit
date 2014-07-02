//
//  NSString+ShellSplitTests.m
//  NSString+ShellSplitTests
//
//  Created by William Kent on 07/01/2014.
//  Copyright (c) 2014 William Kent. All rights reserved.
//

// This #include path is unfortunately brittle (i.e. it is sensitive to the way `pod lib create` creates
// my project, and will break if this happens to change), but it's the only way I can find that will work.
#import "../../NSString+WKShellSplit.h"

SpecBegin(ShellSplit)

describe(@"basic positive tests", ^{
    it(@"should split strings without quotes by whitespace", ^{
        NSString *fixture = @"one two three";
        NSArray *components = [fixture componentsSplitUsingShellQuotingRules];
        expect(components).to.equal(@[ @"one", @"two", @"three" ]);
    });
    
    it(@"should split strings with double quotes properly", ^{
        NSString *fixture = @"one \"two three\" four";
        NSArray *components = [fixture componentsSplitUsingShellQuotingRules];
        expect(components).to.equal(@[ @"one", @"\"two three\"", @"four" ]);
    });
    
    it(@"should split strings with single quotes properly", ^{
        NSString *fixture = @"one 'two three' four";
        NSArray *components = [fixture componentsSplitUsingShellQuotingRules];
        expect(components).to.equal(@[ @"one", @"'two three'", @"four" ]);
    });
    
    it(@"should split strings with both single and double quotes properly", ^{
        NSString *fixture = @"one 'two three' \"four five\" six";
        NSArray *components = [fixture componentsSplitUsingShellQuotingRules];
        expect(components).to.equal(@[ @"one", @"'two three'", @"\"four five\"", @"six" ]);
    });
});

describe(@"basic negative tests", ^{
    it(@"should reject strings with unbalanced single quotes", ^{
        NSString *fixture = @"one 'two three";
        expect(^{ [fixture componentsSplitUsingShellQuotingRules]; }).to.raise(nil);
    });
    
    it(@"should reject strings with unbalanced double quotes", ^{
        NSString *fixture = @"one \"two three";
        expect(^{ [fixture componentsSplitUsingShellQuotingRules]; }).to.raise(nil);
    });
});

SpecEnd

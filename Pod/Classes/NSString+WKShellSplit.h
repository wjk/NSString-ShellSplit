/*
 This method is based on shellwords.rb in Ruby 2.1.1
 See the LICENSE file included with this Pod for details.
 */

#import <Foundation/Foundation.h>

@interface NSString (WKShellSplit)

- (NSArray *)componentsSplitUsingShellQuotingRules;

@end

/*
 This method is based on shellwords.rb in Ruby 2.1.1
 See the LICENSE file included with this Pod for details.
 */

#import "NSString+WKShellSplit.h"

@implementation NSString (WKShellSplit)

- (NSArray *)componentsSplitUsingShellQuotingRules {
    __block NSMutableArray *words = [NSMutableArray array];
    __block NSMutableString *field = [NSMutableString string];
    
    static NSRegularExpression *regex;
    static NSRegularExpression *escapeRemovalRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\G\\s*(([^\\s\\\'\"]+)|'([^\\']*)'|\"((?:[^\\\"\\\\]|\\\\.?)*)|(\\S))(\\s|\\z)?" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        escapeRemovalRegex = [NSRegularExpression regularExpressionWithPattern:@"\\\\(.)" options:0 error:NULL];
        NSAssert(regex != nil, @"Could not compile regex");
        NSAssert(escapeRemovalRegex != nil, @"Could not compile escape-removal regex");
    });
    
    NSString *(^safeSubstringWithRange)(NSString *, NSRange) = ^(NSString *whole, NSRange range){
        // And yes, the nasty (NSString *) nil cast here is necessary.
        if (range.location == NSNotFound && range.length == 0) return (NSString *) nil;
        else return [whole substringWithRange:range];
    };
    
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *word = safeSubstringWithRange(self, [result rangeAtIndex:1]);
        NSString *sq = safeSubstringWithRange(self, [result rangeAtIndex:2]);
        NSString *dq = safeSubstringWithRange(self, [result rangeAtIndex:3]);
        NSString *esc = safeSubstringWithRange(self, [result rangeAtIndex:4]);
        NSString *garbage = safeSubstringWithRange(self, [result rangeAtIndex:5]);
        NSString *sep = safeSubstringWithRange(self, [result rangeAtIndex:6]);
        
        if (garbage.length != 0) [NSException raise:NSInvalidArgumentException format:@"Unmatched quote in string %@", self];
        
        if (word != nil) {
            [field appendString:word];
        } else if (sq != nil) {
            [field appendString:sq];
        } else if (dq != nil) {
            [field appendString:[escapeRemovalRegex stringByReplacingMatchesInString:dq options:0 range:NSMakeRange(0, dq.length) withTemplate:@"$1"]];
        } else if (esc != nil) {
            [field appendString:[escapeRemovalRegex stringByReplacingMatchesInString:esc options:0 range:NSMakeRange(0, esc.length) withTemplate:@"$1"]];
        }
        
        if (sep != nil) {
            [words addObject:field];
            field = [NSMutableString string];
        }
    }];
    
    return words;
}

@end

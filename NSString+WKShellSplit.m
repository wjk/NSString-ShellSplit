/*
 This method is based on shellwords.rb in Ruby 2.1.1
 See the LICENSE file included with this Pod for details.
 */

#import "NSString+WKShellSplit.h"

static NSString *WKSafeSubstring(NSString *whole, NSRange range) {
    if (range.location == NSNotFound && range.length == 0) return nil;
    else return [whole substringWithRange:range];
}

static NSString *WKUnescapeDoubleQuotedString(NSString *original) {
    NSMutableString *retval = [original mutableCopy];
    
    [retval replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:0 range:NSMakeRange(0, retval.length)];
    [retval replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:0 range:NSMakeRange(0, retval.length)];
    
    return retval;
}

static NSString *WKUnescapeSingleQuotedString(NSString *original) {
    return [original stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
}

#pragma mark -

@implementation NSString (WKShellSplit)

- (NSArray *)componentsSplitUsingShellQuotingRules {
    __block NSMutableArray *words = [NSMutableArray array];
    __block NSMutableString *field = [NSMutableString string];
    
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\G\\s*(?>([^\\s\\\'\"]+)|'([^\\']*)'|\"((?:[^\\\"\\\\]|\\\\.?)*)\"|(\\S))(\\s|\\z)?" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        NSAssert(regex != nil, @"Could not compile regex");
    });
    
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *word = WKSafeSubstring(self, [result rangeAtIndex:1]);
        NSString *sq = WKSafeSubstring(self, [result rangeAtIndex:2]);
        NSString *dq = WKSafeSubstring(self, [result rangeAtIndex:3]);
        NSString *garbage = WKSafeSubstring(self, [result rangeAtIndex:4]);
        NSString *sep = WKSafeSubstring(self, [result rangeAtIndex:5]);
        
        if (garbage.length != 0) [NSException raise:NSInvalidArgumentException format:@"Unmatched quote in string %@", self];
        
        if (word != nil) {
            [field appendString:word];
        } else if (sq != nil) {
            [field appendString:WKUnescapeSingleQuotedString(sq)];
        } else if (dq != nil) {
            [field appendString:WKUnescapeDoubleQuotedString(dq)];
        }
        
        if (sep != nil) {
            [words addObject:field];
            field = [NSMutableString string];
        }
    }];
    
    return words;
}

@end

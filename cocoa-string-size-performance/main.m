//
//  main.m
//  cocoa-string-size-performance
//
//  Created by Abhi on 5/29/15.
//  Copyright (c) 2015 ___Abhishek Moothedath___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define ITEMS_COUNT 1000000
#define ITEMS_ARRAY_CHUNK_THRESHOLD 10000

NS_INLINE void performAnalysisUsingSizeWithAttributes(NSArray* items)
{
    double width = 0, timeTaken = 0;
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    for(NSString *item in items)
    {
        width = MAX(width, [item sizeWithAttributes:nil].width);
    }
    timeTaken = -[startDate timeIntervalSinceNow];
    NSLog(@"-----------------------Using [NSString sizeWithAttributes:]------------------\n");
    NSLog(@"Time to measure the width(%f) of %li strings is %f\n\n\n",width, items.count, timeTaken);
}

NS_INLINE void performAnalysisUsingNSAttributedString(NSArray* items)
{
    double width = 0, timeTaken = 0;
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    for(NSString *item in items)
    {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:item];
        width = MAX(width, attributedString.size.width);
    }
    timeTaken = -[startDate timeIntervalSinceNow];
    NSLog(@"-----------------------Using [NSAttributedString size]------------------\n");
    NSLog(@"Time taken to measure the width(%f) of %li strings is %f\n\n\n",width, items.count, timeTaken);
}

NS_INLINE void performAnalysisUsingNSLayoutManager(NSArray* items)
{
    double width = 0, timeTaken = 0;
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [NSTextContainer new];
    [textContainer setLineFragmentPadding:0];
    [layoutManager addTextContainer:textContainer];
    
    NSMutableArray *textStorageObjects = [NSMutableArray new];
    for(NSString *item in items)
    {
        @autoreleasepool {
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:item];
            [textStorage addLayoutManager:layoutManager];
            [textStorageObjects addObject:textStorage];
        }
    }
    timeTaken = -[startDate timeIntervalSinceNow];
    NSLog(@"-----------------------Using NSLayoutManager------------------\n");
    NSLog(@"Time taken to create %li NSTextStorage objects is %f",items.count, timeTaken);
    
    startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    [layoutManager glyphRangeForTextContainer:textContainer];
    width = [layoutManager usedRectForTextContainer:textContainer].size.width;
    timeTaken = -[startDate timeIntervalSinceNow];
    NSLog(@"Time taken to measure the width(%f) of %li strings is %f\n\n\n",width, items.count, timeTaken);
}

NS_INLINE void performAnalysisByChunkingAndReusingLayoutManagerObjects(NSArray* items)
{
    NSMutableArray *chunks = [NSMutableArray new];

    for(NSUInteger i = 0; i < items.count; i++)
    {
        NSUInteger chunkIndex = i / ITEMS_ARRAY_CHUNK_THRESHOLD;
        if(chunks.count <= chunkIndex)
        {
            NSMutableArray *chunk = [NSMutableArray new];
            [chunks addObject:chunk];
        }
        NSMutableArray *chunk = [chunks objectAtIndex:chunkIndex];
        [chunk addObject:[items objectAtIndex:i]];
    }
    
    double width = 0, timeTaken = 0;
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [NSTextContainer new];
    NSTextStorage *textStorage = [NSTextStorage new];
    [textStorage addLayoutManager:layoutManager];
    
    [textContainer setLineFragmentPadding:0];
    [layoutManager addTextContainer:textContainer];
    
    for(NSArray *chunk in chunks)
    {
        for(NSString *item in chunk)
        {
            [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withString:item];
            [layoutManager glyphRangeForTextContainer:textContainer];
            width = MAX(width,[layoutManager usedRectForTextContainer:textContainer].size.width);
        }
    }
    timeTaken = -[startDate timeIntervalSinceNow];
    NSLog(@"-----------------------Reusing NSTextStorage and chunking ------------------\n");
    NSLog(@"Time taken to create %li NSTextStorage objects and measure them is %f",items.count, timeTaken);
}

int main(int argc, const char * argv[])
{
    NSMutableArray *items = [NSMutableArray new];
    
    for(NSUInteger i = 0; i < ITEMS_COUNT; i++)
    {
        double random = (double)arc4random_uniform(1000) / 1000;
        NSString *randomNumber = [NSString stringWithFormat:@"%f", random];
        [items addObject:randomNumber];
    }
    
    performAnalysisUsingSizeWithAttributes(items);
    performAnalysisUsingNSAttributedString(items);
    performAnalysisUsingNSLayoutManager(items);
    performAnalysisByChunkingAndReusingLayoutManagerObjects(items);
    
    return 0;
}

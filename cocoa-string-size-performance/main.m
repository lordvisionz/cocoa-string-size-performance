//
//  main.m
//  cocoa-string-size-performance
//
//  Created by Abhi on 5/29/15.
//  Copyright (c) 2015 ___Abhishek Moothedath___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define ITEMS_COUNT 10000
#define ITEMS_ARRAY_CHUNK_THRESHOLD 1000


NS_INLINE NSArray* splitIntoChunks(NSArray *items, NSUInteger chunkSize)
{
    NSMutableArray *chunks = [NSMutableArray new];
    
    for(NSUInteger i = 0; i < items.count; i++)
    {
        NSUInteger chunkIndex = i / chunkSize;
        if(chunks.count <= chunkIndex)
        {
            NSMutableArray *chunk = [NSMutableArray new];
            [chunks addObject:chunk];
        }
        NSMutableArray *chunk = [chunks objectAtIndex:chunkIndex];
        [chunk addObject:[items objectAtIndex:i]];
    }
    
    return chunks;
}

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

static void performAnalysisUsingNSLayoutManager(NSArray* items)
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

static void performUsingCoreText(NSArray *items)
{
    NSArray *chunks = splitIntoChunks(items, ITEMS_ARRAY_CHUNK_THRESHOLD);
    
    __block double width = 0, timeTaken;
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:12];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX), NULL);
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    for(NSArray *chunk in chunks)
    {
        dispatch_group_async(group, queue, ^{
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc]initWithString:[chunk componentsJoinedByString:@"\n"]
                                                                                             attributes:attributes];
            [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            CFAttributedStringRef stringRef = (__bridge CFAttributedStringRef)mutableString;
            CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString(stringRef);
            CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, mutableString.length), path, NULL);
            
            NSArray *lines = (__bridge NSArray*)CTFrameGetLines(frameRef);
            
            for(id item in lines)
            {
                CTLineRef line = (__bridge CTLineRef)item;
                double lineWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
                width = MAX(width, lineWidth);
            }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    timeTaken = -[startDate timeIntervalSinceNow];
    NSLog(@"-----------------------Using Core Text------------------\n");
    NSLog(@"Time taken to measure the width(%f) of %li strings is %f",width, items.count, timeTaken);
}

static NSString* randomStringWithLength(int len)
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

int main(int argc, const char * argv[])
{
    NSMutableArray *items = [NSMutableArray new];
    
//    for(NSUInteger i = 0; i < ITEMS_COUNT; i++)
//    {
//        double random = (double)arc4random_uniform(1000) / 1000;
//        NSString *randomNumber = [NSString stringWithFormat:@"%f", random];
//        [items addObject:randomNumber];
//    }
    
    for(NSUInteger i = 0; i < ITEMS_COUNT; i++)
    {
        double random = (double)arc4random_uniform(1000) / 1000;
        NSString *randomNumber = randomStringWithLength((int)(random * 100));
        [items addObject:randomNumber];
    }


    performAnalysisUsingSizeWithAttributes(items);
    performAnalysisUsingNSAttributedString(items);
    performAnalysisUsingNSLayoutManager(items);
    performUsingCoreText(items);
    
    return 0;
}

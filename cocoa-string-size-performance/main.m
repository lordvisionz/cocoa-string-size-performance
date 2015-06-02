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

NS_INLINE void performAnalysisUsingNSLayoutManager(NSArray* items)
{
    NSArray *chunks = splitIntoChunks(items, ITEMS_ARRAY_CHUNK_THRESHOLD);
    
    __block double width = 0, timeTaken = 0;
    __block NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [NSTextContainer new];
    [textContainer setLineFragmentPadding:0];
    [layoutManager addTextContainer:textContainer];
    
    NSMutableArray *textStorageObjects = [NSMutableArray new];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    for(NSArray *chunk in chunks)
    {
        NSTextStorage *textStorage = [NSTextStorage new];
        dispatch_group_async(group, queue, ^
        {
            [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withString:[chunk componentsJoinedByString:@"\n"]];
        });
        [textStorageObjects addObject:textStorage];
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    for(NSTextStorage *textStorage in textStorageObjects)
    {
        [textStorage addLayoutManager:layoutManager];
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

int main(int argc, const char * argv[])
{
    NSMutableArray *items = [NSMutableArray new];
    
    for(NSUInteger i = 0; i < ITEMS_COUNT; i++)
    {
        double random = (double)arc4random_uniform(1000) / 1000;
        NSString *randomNumber = [NSString stringWithFormat:@"%f", random];
        [items addObject:randomNumber];
    }
    
//    performAnalysisUsingSizeWithAttributes(items);
//    performAnalysisUsingNSAttributedString(items);
    performAnalysisUsingNSLayoutManager(items);
    
    return 0;
}

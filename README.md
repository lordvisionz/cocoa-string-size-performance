# cocoa-string-size-performance
This is a console application in Cocoa to show the various ways to measure the width of text and its performance. There are 3 ways(that I figured out) to do this:

1)  [NSString sizeWithAttributes:]
2)  [NSAttributedString size]
3)  NSLayoutManagerÊ(get text width instead of height)

Here are some performance metrics

Count\Mechanism    sizeWithAttributes    NSAttributedString    NSLayoutManager
1000               0.057                 0.031                 0.007
10000              0.329                 0.325                 0.064
100000             3.06                  3.14                  0.689
1000000            29.5                  31.3                  7.06


# cocoa-string-size-performance
This is a console application in Cocoa to show the various ways to measure the width of text and its performance. There are 3 ways(that I figured out) to do this:


<li>[[NSString sizeWithAttributes:]](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSString_AppKitAdditions/index.html#//apple_ref/occ/instm/NSString/sizeWithAttributes:)
<li> [[NSAttributedString size]](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/NSAttributedString_UIKit_Additions/index.html#//apple_ref/occ/instm/NSAttributedString/size)
<li> [NSLayoutManager](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html#//apple_ref/doc/uid/20001809-CJBGBIBB) (get text width instead of height) 
<br><br>

Here are some performance metrics   
<pre><b>Count\Mechanism</b>    <b>sizeWithAttributes</b>    <b>NSAttributedString</b>    <b>NSLayoutManager</b></pre>
<pre><b>1000</b>               <b>0.057</b>                 <b>0.031</b>                 <b>0.007</b></pre>
<pre><b>10000</b>              <b>0.329</b>                 <b>0.325</b>                 <b>0.064</b></pre>
<pre><b>100000</b>             <b>3.06</b>                  <b>3.14</b>                  <b>0.689</b></pre>
<pre><b>1000000</b>            <b>29.5</b>                  <b>31.3</b>                  <b>7.06</b></pre>


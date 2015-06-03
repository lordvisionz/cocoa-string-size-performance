# cocoa-string-size-performance
This is a console application in Cocoa to show the various ways to measure the width of text and its performance. There are 3 ways(that I figured out) to do this:


<li>[[NSString sizeWithAttributes:]](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSString_AppKitAdditions/index.html#//apple_ref/occ/instm/NSString/sizeWithAttributes:)
<li> [[NSAttributedString size]](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/NSAttributedString_UIKit_Additions/index.html#//apple_ref/occ/instm/NSAttributedString/size)
<li> [NSLayoutManager](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html#//apple_ref/doc/uid/20001809-CJBGBIBB) (get text width instead of height) 
<br><br>

To play with the project, download the file, open up main.m. <br>
<ol>
<li>Change ITEMS_COUNT to the number of strings you want measured.
<li>Change ITEMS_ARRAY_CHUNK_THRESHOLD to chunk up a big array into small arrays.

Here are some performance metrics on my Macbook Pro running Yosemite 2.3GHz Intel i7 and 8GB memory.
<pre><b>Count\Mechanism</b>    <b>sizeWithAttributes</b>    <b>NSAttributedString</b>    <b>NSLayoutManager</b></pre>
<pre><b>1000</b>               <b>0.057</b>                 <b>0.031</b>                 <b>0.007</b></pre>
<pre><b>10000</b>              <b>0.329</b>                 <b>0.325</b>                 <b>0.064</b></pre>
<pre><b>100000</b>             <b>3.06</b>                  <b>3.14</b>                  <b>0.689</b></pre>
<pre><b>1000000</b>            <b>29.5</b>                  <b>31.3</b>                  <b>7.06</b></pre>

<b>NOTE:</b> The NSLayoutManager mechanism creates an NSTextStorage object for every string. These objects are very heavyweight and memory intensive. By just creating 1 and re-using them however causes layout to happen for every string and the measurement time goes up to 40 seconds for a million strings.

<h1>UPDATE</h1>
Using CoreText is the way to go. For the above table.
<pre><b>Count\Mechanism</b>    <b>Core Text without Multithreading</b>    <b>Core Text with Multithreading</b>
<pre><b>1000</b>               <b>0.018</b>                 <b>0.02</b></pre>               
<pre><b>10000</b>              <b>0.023</b>                 <b>0.023</b></pre>            
<pre><b>100000</b>             <b>0.161</b>                  <b>0.061</b></pre>                   
<pre><b>1000000</b>            <b>1.46</b>                  <b>0.447</b></pre>          

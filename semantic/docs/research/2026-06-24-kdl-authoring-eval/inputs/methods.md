# Methods to annotate (identical for every arm)

Each row is a real-shape macOS API method. Annotate EVERY one. Fields in the
"facts" are mechanical; you supply the semantic annotation per the vocabulary.

1. class=NSString  selector=`stringByAppendingString:`  instance=yes
   facts: returns a new NSString; arg is an NSString.
2. class=NSMutableDictionary  selector=`setObject:forKey:`  instance=yes
   facts: stores value under key; key is copied.
3. class=NSData  selector=`writeToURL:atomically:encoding:error:`  instance=yes
   facts: writes to disk; last arg is NSError**; returns BOOL.
4. class=NSString  selector=`replaceCharactersInRange:withString:`  instance=yes
   facts: mutates receiver in place.
5. class=NSArray  selector=`sortedArrayUsingComparator:`  instance=yes
   facts: takes a comparator block invoked synchronously during the call; returns new array.
6. class=NSNotificationCenter selector=`addObserverForName:object:queue:usingBlock:` instance=yes
   facts: block is stored and invoked later on the given queue; returns an opaque observer token (owned by caller until removeObserver:).
7. class=URLSession  selector=`data(for:delegate:)`  instance=yes
   facts: Swift async; returns (Data, URLResponse); can throw.
8. class=Combine.Publisher selector=`combineLatest(_:_:_:_:)` instance=yes
   facts: last arg is a transform closure, stored for the publisher's lifetime.
9. class=NSWindow  selector=`makeKeyAndOrderFront:`  instance=yes
   facts: must run on the main thread; mutates UI.
10. class=NSFileManager selector=`contentsOfDirectoryAtURL:includingPropertiesForKeys:options:error:` instance=yes
    facts: NSError** out-param; returns NSArray* or nil on failure.
11. class=NSObject  selector=`valueForKeyPath:`  instance=yes
    facts: may raise NSException for an unknown key path.
12. class=NSScanner selector=`scanString:intoString:` instance=yes
    facts: out-param NSString** valid only when it returns YES.
13. class=NSColor  selector=`colorWithRed:green:blue:alpha:`  instance=no (class method)
    facts: factory; returns autoreleased NSColor.
14. class=NSRegularExpression selector=`enumerateMatchesInString:options:range:usingBlock:` instance=yes
    facts: block invoked synchronously per match; block must not call back into the regex.
15. class=DispatchQueue selector=`async(execute:)` instance=yes
    facts: block is escaping, invoked later on a private thread.
16. class=NSPasteboard selector=`writeObjects:` instance=yes
    facts: array elements are retained by the pasteboard.
17. class=NSView selector=`addSubview:` instance=yes
    facts: parent retains child; main-thread only.
18. class=NSURLSession selector=`dataTaskWithRequest:completionHandler:` instance=yes
    facts: completion handler called once, on a background delegate queue.
19. class=NSString selector=`writeToFile:atomically:encoding:error:` instance=yes
    facts: deprecated in favor of writeToURL:...; NSError** out-param.
20. class=NSDateFormatter selector=`stringFromDate:` instance=yes
    facts: not thread-safe; the receiver's mutable state means callers on multiple threads must synchronize.

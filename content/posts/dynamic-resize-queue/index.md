+++
title = 'Dynamically Resizing Queue'
date = 2024-06-26T23:17:35-07:00
draft = false
+++

> This post builds on the [Event Queue Service](/posts/event-queue-service) post I made earlier. In that post, I made an event queue service that could handle up to a fixed number of events. In this post, I will upgrade my queue implementation to dynamically resize itself when it reaches its capacity.

## Introduction

In the previous post, I made an event queue service using a ring buffer. The ring buffer had a fixed size, and when it reached its capacity, it would not accept any more events. In this post, I'll be making some changes to the queue implementation to allow it to resize itself when it reaches its capacity. I'll be taking inspiration from the `ArrayList` class in Java, which doubles in size when it reaches its capacity. This is going to be a short post.

## Implementation

The implementation is quite simple. My ring buffer implementation needs only one new function, `ensureCapacity`, which would essentially do exactly what `ArrayList` does in Java. It creates a new buffer with twice the capacity of the old one and copies all the elements from the old buffer into the new one. It then updates the head and tail pointers to point to the correct elements in the new buffer.

I also need to update the `Enqueue` function to call `ensureCapacity` every time it is called. You can see the diff below:

```diff
diff --git a/ringbuffer.go b/ringbuffer.go
index c87e550..962e792 100644
--- a/ringbuffer.go
+++ b/ringbuffer.go
@@ -1,6 +1,9 @@
 package main

-import "errors"
+import (
+       "errors"
+       "math"
+)

 type RingBuffer struct {
        buffer []interface{}
@@ -18,9 +21,27 @@ func NewRingBuffer(capacity int) *RingBuffer {
        }
 }

+func ensureCapacity(rb *RingBuffer, minCapacity int) error {
+       current := len(rb.buffer)
+       if minCapacity <= current {
+               return nil
+       }
+       if current*2 > math.MaxInt {
+               return errors.New("error: cannot ensure capacity for a buffer that is too large")
+       }
+       newBuffer := make([]interface{}, current*2)
+       for i := 0; i < rb.size; i++ {
+               newBuffer[i] = rb.buffer[(rb.head+i)%current]
+       }
+       rb.buffer = newBuffer
+       rb.head = 0
+       rb.tail = rb.size
+       return nil
+}
+
 func (rb *RingBuffer) Enqueue(item interface{}) error {
-       if rb.size == len(rb.buffer) {
-               return errors.New("error: cannot enqueue to a full buffer")
+       if err := ensureCapacity(rb, rb.size+1); err != nil {
+               return err
        }
        rb.buffer[rb.tail] = item
        rb.tail = (rb.tail + 1) % len(rb.buffer)
```

## Conclusion

That was quick! Now my event queue service won't run out of space when it reaches its capacity.

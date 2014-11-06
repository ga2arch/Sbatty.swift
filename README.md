Sbatty.swift
============

Simple cmd line reminder written in swift, useful to remember to do little stuff in time 

Example:

make a simple sbatty, bash script and put it into /usr/local/bin
```
#!/bin/bash

cd ~/Library/Developer/Xcode/DerivedData/Sbatty-code/Build/Products/Debug/Sbatty.app/Contents/MacOS/
./Sbatty $@
```

then use it like this:

```
sbatty in 10s
```

after 10s it'll start to beep and show a notification


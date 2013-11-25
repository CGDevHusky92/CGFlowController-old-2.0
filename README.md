CGFlowController By Charles Gorectke
====================================

An easy to use Pan gesture controller that you can use to attach and pan multiple views in both the X and Y direction.

I wanted a simple customizable view set up to easily transition different views. So I decided to start to build my own.
This was all prior to storyboards. So this needs a lot of updating. I wanted a way to add views that needed to stay live
in memory and not be deallocated. While still having the ability to lazy load any view I wanted. I need a better mapping
technique for the entire layout. It also needs to be tested for ridiculous layouts that span like crazy. Also I believe
wrap around was broken when updating for a specific project and needs to be looked at. Also any memory leaks need to be
addressed.


Things to add:
==============
Storyboard support
View method transition exectution (viewWillAppear,disappear,etc)
better delegate support
larger more customizable code base for live, non-live views

Known Issues:
=============
Wrap around is very easily broken.
Mapping can break based on diagonal view loading. Diagonal views can never be loaded and views need to be loaded based on
previous views not being nil.




As always have fun use at your own risk and don't blame me if things don't work. This is just a side project for learning.
If you actually need help with anything feel free to contact me and I'll gladly try to help. I am sublicensing this under
an MIT license, so go out use it and have fun.
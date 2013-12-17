CGFlowController v2.0.0 
  By Charles Gorectke
=======================

An easy to use Pan gesture controller that you can use to attach and pan multiple views in both the X and Y direction.
As of version 2.0.0 I have added StoryBoard support and have shown how to use it in the Demo. Storyboard support comes
as the default setting. I will slowly be dropping support for the previous nib support and continue moving on with a more
robust library that can be plugged into StoryBoards.


I wanted a simple customizable view set up to easily transition different views. So I decided to start to build my own.
This was all prior to storyboards. So this needs a lot of updating. I wanted a way to add views that needed to stay live
in memory and not be deallocated. While still having the ability to lazy load any view I wanted. I need a better mapping
technique for the entire layout. It also needs to be tested for ridiculous layouts that span like crazy. Also I believe
wrap around was broken when updating for a specific project and needs to be looked at.




Features:
=========
CGFlowController provides a simple delegate for code to run on transition start and end.
Allows an easy subclass of CGPanelView to modify existing view controllers easily by swapping a few method names.
Allows pan transitions in both the x and y direction.
Allows easy transition anywhere in the map provided just by giving x and y coordinates.
Allows live and none live views for easier memory management.


Things to add/check:
====================
Better delegate support
Better view handling with StoryBoards.
Check view loading and unloading based on display.


Known Issues:
=============
Wrap around is very easily broken.
Mapping can break based on diagonal view loading. Diagonal views can never be loaded and views need to be loaded based on
previous views not being nil.


Considerations:
===============
As always have fun use at your own risk and don't blame me if things don't work. This is just a side project for learning.
If you actually need help with anything feel free to contact me and I'll gladly try to help. I am sublicensing this under
an MIT license, so go out use it and have fun.
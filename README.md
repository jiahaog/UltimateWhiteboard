UltimateWhiteboard
==================
An universal iOS application designed to act as a virtual whiteboard for the Ultimate Frisbee Sport. 
Animations made with [Facebook's Pop animation framework](https://github.com/facebook/pop)

Compatible with iOS 7.x - 8.1

## Functions
* Two finger pinch to select and manipulate multiple markers
* Toggle between built in formations
* Keyframe animation system to record and playback tactics

## Getting Started
1. Clone the repo
2. With [cocoapods](http://cocoapods.org) installed, run `pod install` from the cloned folder
3. Open `Ultimate Whiteboard.xcworkspace` in XCode
4. Run the project

## User Interface Considerations
The markers will animate themselves a few points up from the original `touches` location when touched, so that the user's finger does not obstruct the display of the marker.

## Work in progress
* Replace placeholder buttons with proper buttons
* Integrate [Everplay API](https://developers.everyplay.com) recording functionality to allow users to add commentary and share their plays on online social platforms
* Expand touch area on iPad to facilitate interaction

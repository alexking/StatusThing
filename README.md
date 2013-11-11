StatusThing
===========

Mac app status bar app for SmartThings

![screenshot](screenshot.png)

## Download
Currently, the app has to be built from source so that you can add your OAuth keys. I'm currently working on adding an interface for this so this won't be necessary, and binary downloads can be offered. 

## Build Instructions 
Before opening in Xcode, install [CocoaPods](http://cocoapods.org) and run `pod` in the root directory to include all dependencies.  

## Installation Instructions 

Currently there is no way to publish a SmartApp for everyone to use, so you have to create a SmartApp with the right code yourself before using StatusThing. The code for the SmartApp is located at [app.groovy](app.groovy).

1. Login to the [SmartThings Developer IDE](https://graph.api.smartthings.com)
2. Create a new SmartApp – fill in the required fields, and then click `Enable OAuth in Smart App` - this will provide you with a pair of OAuth Client keys. Start up the StatusThing app and click `Preferences` in the menu, then copy these keys into the kClientId and kClientSecret section of AppDelegate.m 
3. Click the `Create` button in the SmartThings IDE, which will bring up code. Copy the contents of [app.groovy](app.groovy) and paste it into the IDE, then click `Save`, and `Publish` &rarr; `For Me` (important step). 
4. Build the app, then click `Preferences`, and the `Authorize` button under accounts. You'll be redirected to a page where you can set which devices the app can access
5. Enjoy!

## Notes
The app uses the AKSmartThings library, which you can get [here to use in your own projects](https://github.com/alexking/AKSmartThings). 
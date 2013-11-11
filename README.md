StatusThing
===========

Mac app status bar app for SmartThings

## Download
You can download a `.zip` of the compiled app here. 

## Installation Instructions 

Currently there is no way to publish a SmartApp for everyone to use, so you have to create a SmartApp with the right code yourself before using StatusThing. The code for the SmartApp is located at [app.groovy](app.groovy).

1. Login to the [SmartThings Developer IDE](https://graph.api.smartthings.com)
2. Create a new SmartApp – fill in the required fields, and then click `Enable OAuth in Smart App` - this will provide you with a pair of OAuth Client keys. Start up the StatusThing app and click `Preferences` in the menu, then copy these keys over to the accounts screen. 
3. Click the `Create` button in the SmartThings IDE, which will bring up code. Copy the contents of [app.groovy](app.groovy) and paste it into the IDE, then click `Save`, and `Publish` &rarr; `For Me` (important step). 
4. You're ready to use the app now! Click `Preferences` again and then click the `Authorize` button under accounts. You'll be redirected to a page where you can set which devices the app can access, 

## Build Instructions 
Before opening in Xcode, install [CocoaPods](http://cocoapods.org) and run `pod` in the root directory to include all dependencies.  
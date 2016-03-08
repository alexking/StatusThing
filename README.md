StatusThing
===========

**Note:** I'm not actively working on this project as I don't use SmartThings much anymore. I'd encourage people who are interested to fork the project - I'd be happy to link your more maintained version from here!

![screenshot](screenshot.png)

## UPDATES: Only two small changes from orignal.
1. Code being pasted into Smartthings (which needs to replace pre-existing code auto-populated by Smartthings) needs an opening: Add '/' to column 2, line 2 for the first line, "/*  Statusthing"
2. NOT working for OS X 10.10 Yosemite yet. Upon final step Authorizing, local app crashes not allowing authorization to finalize.

## Download
You can [download the app here](http://alexking.io/StatusThing) (tested on OSX 10.9 only). It's just version 0.1, so please post any issues you encounter!

## Installation Instructions 

Currently there is no way to publish a SmartApp for everyone to use, so you have to create an app with the code yourself before using the mac app. The code for the SmartApp is located at [app.groovy](app.groovy).

1. Login to the [SmartThings Developer IDE](https://graph.api.smartthings.com)
2. Create a new SmartApp – fill in the required fields, and then click `Enable OAuth in Smart App` - this will provide you with a pair of OAuth Client keys. Start up the StatusThing app and copy these keys into the preferences section. 
3. Click the `Create` button in the SmartThings IDE, which will bring up code. Copy the contents of [app.groovy](app.groovy) and paste it into the IDE, then click `Save`, and `Publish` &rarr; `For Me` (important step). 
4. Go back to preferences and click the `Authorize` button under accounts. You'll be redirected to a page where you can set which devices the app can access.
5. Enjoy!

## Build Instructions 
If you're building the app from source, be sure to install [CocoaPods](http://cocoapods.org) and run `pod` in the root directory to include all dependencies.  

## Notes
The app uses the AKSmartThings library, which you can get [here to use in your own projects](https://github.com/alexking/AKSmartThings). 

## License
[MIT License](LICENSE)

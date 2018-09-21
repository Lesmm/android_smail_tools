
## Usage

### First. Connect your device(root) to your PC:

	adb root
	adb shell ls /data/app

	
### Second. Open Terminal:

    apk.sh com.xxx.xxx.apk	// it will generate the folder 'com.xxx.xxx', the smali codes in it


### Third. Install java2smali to Android Studio:

	1. Settings(Alt+Ctrl+S) -> Plugins -> Search java2smali, install and restart
	2. Reference: https://github.com/ollide/intellij-java2smali


### Fourth. Modify Smali codes、Debug、Pack/Repack apk.
	
	1. New a JavaSE Porject
	2. Unchecked 'Use default location'
	3. Reference to folder 'com.xxx.xxx'.
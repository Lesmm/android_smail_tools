
## Usage

### First. Connect your device(root) to your PC:

	adb root
	adb shell ls /data/app



### Second. Modify Smali codes、Debug、Pack/Repack apk.
	
	apk.sh com.xxx.xxx.apk	// it will generate the folder 'com.xxx.xxx', the smali codes in it
	1. New a JavaSE Porject
	2. Unchecked 'Use default location'
	3. Reference to folder 'com.xxx.xxx'.


### Fourth. Install java2smali to Android Studio:

	1. Settings(Alt+Ctrl+S) -> Plugins -> Search java2smali, install and restart
	2. Reference: https://github.com/ollide/intellij-java2smali
	3. File -> New -> Import Project... -> Reference to new dumped folder 'com.xxx.xxx'.

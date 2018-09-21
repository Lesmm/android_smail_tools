
## Usage

### 1. Connect your device(root) to your PC:

	adb root
	adb shell ls /data/app



### 2. Modify Smali codes、Debug、Pack/Repack apk in Eclipse
	
	apk.sh com.xxx.xxx.apk	// it will generate the folder 'com.xxx.xxx', the smali codes in it
	1. New a JavaSE Porject
	2. Unchecked 'Use default location'
	3. Reference to folder 'com.xxx.xxx'.


### 3. Install java2smali, debug in Android Studio

1. Settings(Alt+Ctrl+S) -> Plugins -> Search [java2smali](https://github.com/ollide/intellij-java2smali), install and restart.
2. Settings(Alt+Ctrl+S) -> Plugins -> Install plugin from disk..., download (smalidea.zip)[https://bitbucket.org/JesusFreke/smali/downloads/] install and restart
3. File -> New -> Import Project... -> Reference to folder 'com.xxx.xxx'. (Do not used by Eclipse proj)
4. Issue for example: adb shell am start -D -n package_name/main_activity
5. Then add a Remote Run/Debug Configuration, set port to 8700. Make some breakpoints. 

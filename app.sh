#!/bin/bash

# Usage:
# Connect your device, confirm you have install the apk: adb shell ls /data/app
# app.sh com.yourdream.app.android
# app.sh com.yourdream.app.android-1.apk
# app.sh -P com.yourdream.app.android

# log function
function ilog {
	echo ""
	echo "----- $1"
	echo ""
}

if [[ $1 = "" ]]; then
	ilog "No arguments"
	exit 1
fi


# run adb as root
adb root

# get the configs and variables
apktool_wrapper_script_path=./apktool_2.3.4/apktool_2.3.4.bat
signapk_tool_dir=./other_tools/signapk/

__OPTION__=$1
PROJECT_NAME=""


if [[ $__OPTION__ == "-P" ]];then
	PROJECT_NAME=$2
	PROJECT_NAME=${PROJECT_NAME/%\//}
else
	apkName=$1

	# get the .apk file path
	if [[ $apkName =~ \.apk$ ]]; then
		echo "With .apk suffix"
	else
		echo "Without .apk suffix"
		apkName=`adb shell ls //data/app/ | grep ${apkName}` 
	fi

	apkPath=//data/app/$apkName
	echo "APK path is: ${apkPath}"

	PROJECT_NAME=${apkName/%-*/}
	echo "Porject name is: ${PROJECT_NAME}"
	

	# download the .apk file. For windows's git-bash
	ilog "Pulling: $apkPath"
	adb pull $apkPath

	# decomplie the .apk file
	if [ ! -f "${apkName}" ]; then
		ilog "Apk file not exists"
		exit 1
	else
		ilog "Pull apk successfully"	
	fi
	ilog "Decompling: $apkName"
	temp_pull_dir=${apkName/.apk/_apk}
	${apktool_wrapper_script_path} d $apkName -f -o $temp_pull_dir
	
	# for eclipse project
	if [ ! -d "${PROJECT_NAME}" ]; then
		mkdir ${PROJECT_NAME}
	fi

	pushd ${PROJECT_NAME}
	ls | grep -E -v ".classpath|.project|.settings" | xargs rm -rf
	popd

	mv ${temp_pull_dir}/* ${PROJECT_NAME}/
	rm -rf ${temp_pull_dir}
fi



# get the package name 
manifestfileName=$PROJECT_NAME/AndroidManifest.xml
packageName=`cat $manifestfileName | grep package | sed -n 's/.*package="//p' | tr "\"" "\n" | head -n 1`
ilog "Get the package name: $packageName"


# get the main activity name
mainActivityName=`cat $manifestfileName  | grep -B 5 "android.intent.action.MAIN" | grep "android:name" | awk -F "android:name" '{print $2}' | awk -F "\"" '{print $2}' | tail -2 | head -1`
if [[ $mainActivityName =~ "." ]]; then
	echo ''
else
	mainActivityName=".${mainActivityName}"
fi
ilog "Get the main activity name: $mainActivityName"
mainActivityPath=$packageName/$mainActivityName



# insert the debuggabel flag
tmpString="android:debuggable=\"true\""
applicationString=`cat $manifestfileName | grep "<application "`
echo "$applicationString" | grep -q "$tmpString"
if [ $? -eq 1 ]; then
	ilog "Inserting android:debuggable='true' flag"
	sed -i -e 's/<application /<application android:debuggable="true" /g' $manifestfileName
	ilog "Inserted android:debuggable=\"true\" to AndroidManifest.xml"
else
	ilog "No need to insert android:debuggable=\"true\" to AndroidManifest.xml"
fi




# wait for modify smali job done
if [[ $__OPTION__ == "-P" ]];then
	ilog "Project Mode(With -P OPTION), Let's continue ..."
else
	for((i=1;i<=3;i++));
	do
		ilog "i.e. ${mainActivityName}.onCreate(Android):"
		echo "a=0;// 	invoke-static {}, Landroid/os/Debug;->waitForDebugger()V"
		ilog "After Changed Smali Codes, Press ENTER (or Ctrl-C to cancel):"
		read -s -n 1 key
		if [[ $key = "" ]]; then
			break
		else
			continue
		fi
	done
fi


# generate debug file
debugfile="${PROJECT_NAME}_debug.apk"
ilog "Generating: $debugfile"
${apktool_wrapper_script_path} b $PROJECT_NAME -o $debugfile


# generate signed file
signedfile=${debugfile/.apk/_signed.apk}
ilog "Signing: $signedfile"
java -jar ${signapk_tool_dir}/signapk.jar ${signapk_tool_dir}/key.media.x509.pem ${signapk_tool_dir}/key.media.pk8 $debugfile $signedfile


# unistall the old app and install the new one
ilog "Unistalling ..."
adb uninstall $packageName
ilog "Installing ..."
adb install $signedfile


# launch the debug apk
ilog "Run: adb shell am start -n $mainActivityPath"
ilog "Debug: adb shell am start -D -n $mainActivityPath"
ilog "For Debug, make sure you have close your origin project and set breakpoint in your remote debug smali codes"
ilog "Press 'ENTER' key to Debug, Press 'R/r' to Run :"
read -s -n 1 key
if [[ $key == "" ]]; then
	ilog "Debuging..."
	adb shell am start -D -n $mainActivityPath
elif [[ $key == "r" ]] || [[ $key == "R" ]]; then
	ilog "running..."
	adb shell am start -n $mainActivityPath
else
	ilog "Cancel Launch."
fi

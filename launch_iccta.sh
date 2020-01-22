#!/bin/bash

print_info () {
    echo "[*] $1"
}

while getopts a:p: option
do
    case "${option}"
        in
        a) APP_PATH=${OPTARG};;
        p) ANDROID_JAR=${OPTARG};;
    esac
done

echo "IccTA launcher"
echo
if [ -z "$APP_PATH" ]
then
    read -p "Path of APK: " APP_PATH
fi
if [ -z "$ANDROID_JAR" ]
then
    read -p "Path to android.jar: " ANDROID_JAR
fi

cp $APP_PATH ./soot-infoflow-android-iccta &> /dev/null
cd soot-infoflow-android-iccta

APP_BASENAME_APK=$(basename $APP_PATH .apk)
APP_BASENAME=$(basename $APP_PATH)
DARE_RESULTS=dareResults
RETARGETED_PATH=$DARE_RESULTS/retargeted
PATH_LOGS=logs

if [ ! -d $PATH_LOGS ]
then
    mkdir $PATH_LOGS
fi

print_info "Retargeting $APP_BASENAME"
./dare/dare -d ../$DARE_RESULTS ../$APP_BASENAME &> $PATH_LOGS/$APP_BASENAME-dare.txt

print_info "Resolving ICC model"
java -jar ic3.jar -input $RETARGETED_PATH/$APP_BASENAME_APK -apkormanifest $APP_BASENAME -cp $ANDROID_JAR -db cc.properties &> $PATH_LOGS/$APP_BASENAME-ic3.txt

print_info "Executing IccTA"
java -jar iccta.jar $APP_BASENAME $ANDROID_JAR &> $PATH_LOGS/$APP_BASENAME-iccta.txt

print_info "$APP_BASENAME successfully analyzed."
print_info "Check results in soot-infoflow-android-iccta/$PATH_LOGS/"

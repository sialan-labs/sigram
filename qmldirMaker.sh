#! /bin/sh
# Set the home if not already set.
if [ "${ASEMAN_SRC_PATH}" = "" ]; then
    ASEMAN_SRC_PATH="`echo $0 | grep ^/`"
    if [ "$ASEMAN_SRC_PATH" = "" ]; then
	ASEMAN_SRC_PATH="$PWD"/"$0"
    fi
    cd `dirname $ASEMAN_SRC_PATH`
    ASEMAN_SRC_PATH=$PWD
    cd -
fi

cd $ASEMAN_SRC_PATH 

FILES=`find . -name qmldir`
for FILE in $FILES
do
    DIR=`dirname "$FILE"`
    [ $DIR = "./thirdparty" ] && continue
    rm "$FILE"
done

FILES=`find . -name "*.qml"`
for FILE in $FILES
do
    DIR=`dirname "$FILE"`
    [ $DIR = "./thirdparty" ] && continue
    QMLDIRFILE="$DIR/qmldir"
    COMPONENT=`basename "$FILE" .qml`
    FILENAME=`basename "$FILE"`
    
    STRLINE="$COMPONENT 1.0 $FILENAME"
    if [ $DIR = "./globals" ]
    then
        STRLINE="singleton $STRLINE"
    fi
    if [ $DIR = "./awesome" ]
    then
        STRLINE="singleton $STRLINE"
    fi
    
    echo "$STRLINE" >> "$QMLDIRFILE"
done


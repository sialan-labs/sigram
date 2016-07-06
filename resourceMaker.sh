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

FILES=`find . -name "*.qml" -o -name "*.js" -o -name "*.ttf" -o -name "*.jpg" -o -name "qmldir" -o -name "*.txt" -o -name "*.ogg"`

echo  "<RCC>
    <qresource prefix=\"/\">
        <file>inputs/images/Salvador.png</file>
        <file>messages/files/default_background.png</file>" > resource.qrc

for FILE in $FILES
do
    echo "        <file>$FILE</file>" >> resource.qrc
done

echo "    </qresource>
</RCC>
" >> resource.qrc

cd "emojis"

FILES=`find . -name "*.png"`

echo  "<RCC>
    <qresource prefix=\"/emojis\">" > emojis.qrc

for FILE in $FILES
do
    echo "        <file>$FILE</file>" >> emojis.qrc
done

echo "    </qresource>
</RCC>
" >> emojis.qrc

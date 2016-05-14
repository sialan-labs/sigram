#! /bin/sh

rm "qmldir"
for QML_FILE in *.qml
do
    COMPONENT=`basename -s ".qml" "$QML_FILE"`
    echo "$COMPONENT 1.0 $QML_FILE" >> "qmldir"
done

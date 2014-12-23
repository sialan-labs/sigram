#! /bin/sh

# Set the home if not already set.
if [ "${KAQAZ_SRC_PATH}" = "" ]; then
    KAQAZ_SRC_PATH="`echo $0 | grep ^/`"
    if [ "$KAQAZ_SRC_PATH" = "" ]; then
    KAQAZ_SRC_PATH="$PWD"/"$0"
    fi
    cd `dirname $KAQAZ_SRC_PATH`
    KAQAZ_SRC_PATH=$PWD
    cd -
fi

cd $KAQAZ_SRC_PATH
for TRANSLATION in ./translations_sources/*.ts
do
    /opt/Qt5.4.0/5.4/gcc_64/bin/lupdate `find -name '*.cpp' -type f` \
            `find -name '*.qml' -type f` \
            `find -name '*.h' -type f` \
            `find -name '*.ui' -type f` \
            -ts "$TRANSLATION"
done


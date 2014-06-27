#! /bin/sh

# Set the home if not already set.
if [ "${SIALAN_SRC_PATH}" = "" ]; then
    SIALAN_SRC_PATH="`echo $0 | grep ^/`"
    if [ "$SIALAN_SRC_PATH" = "" ]; then
    SIALAN_SRC_PATH="$PWD"/"$0"
    fi
    cd `dirname $SIALAN_SRC_PATH`
    SIALAN_SRC_PATH=$PWD
    cd -
fi

cd $SIALAN_SRC_PATH
for TRANSLATION in ./translations_sources/*.ts
do
    lupdate `find -name '*.cpp' -type f` \
            `find -name '*.qml' -type f` \
            `find -name '*.h' -type f` \
            `find -name '*.ui' -type f` \
            -ts "$TRANSLATION"
done


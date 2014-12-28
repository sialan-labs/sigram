isEmpty(QMAKE_QMLPLUGINDUMP) {
    win32:QMAKE_QMLPLUGINDUMP = $$[QT_INSTALL_BINS]/qmlplugindump.exe
    else:QMAKE_QMLPLUGINDUMP = $$[QT_INSTALL_BINS]/qmlplugindump
}

qmldirSrc = $$_PRO_FILE_PWD_/qml/AsemanTools/qmldir
qmkdirDst = $$OUT_PWD/$$DESTDIR/qmldir
qmkdirDst2 = $$OUT_PWD/qmldir

win32 {
    qmldirSrc = $$replace(qmldirSrc, /, \\)
    qmldirSrc ~= s,\\\\\\.?\\\\,\\,

    qmkdirDst = $$replace(qmkdirDst, /, \\)
    qmkdirDst ~= s,\\\\\\.?\\\\,\\,

    qmkdirDst2 = $$replace(qmkdirDst2, /, \\)
    qmkdirDst2 ~= s,\\\\\\.?\\\\,\\,
}

dmpPluginCommand = $(COPY_FILE) $$qmldirSrc $$qmkdirDst
dmpPluginCommand = $$dmpPluginCommand && echo plugin $$TARGET >> $$qmkdirDst
dmpPluginCommand = $$dmpPluginCommand && $(COPY_FILE) $$qmkdirDst $$qmkdirDst2
unix {
    dmpPluginCommand = $$dmpPluginCommand && LD_LIBRARY_PATH=$$OUT_PWD/$$DESTDIR:$$PREFIX
    dmpPluginCommand = $$dmpPluginCommand $$QMAKE_QMLPLUGINDUMP $$uri 1.0 $$OUT_PWD/$$DESTDIR/.. > $$OUT_PWD/$$DESTDIR/plugins.qmltypes
} win32 {
    CONFIG(debug, debug|release) {
    } else {
        libsPath = $$OUT_PWD/../build
        libsPath = $$replace(libsPath, /, \\)
        libsPath ~= s,\\\\\\.?\\\\,\\,

        prefixPath = $$PREFIX
        prefixPath = $$replace(prefixPath, /, \\)
        prefixPath ~= s,\\\\\\.?\\\\,\\,

        dmpPluginCommand = $$dmpPluginCommand && SET PATH=%PATH%;$$libsPath;$$prefixPath
        dmpPluginCommand = $$dmpPluginCommand&& $$QMAKE_QMLPLUGINDUMP $$uri 1.0 $$OUT_PWD/$$DESTDIR/.. > $$OUT_PWD/$$DESTDIR/plugins.qmltypes
    }
}
dmpPluginCommand = @echo Generating plugin types file... && $$dmpPluginCommand

dmpPluginDeploymentfolders.commands = $$dmpPluginCommand

QMAKE_POST_LINK += $$dmpPluginCommand

TEMPLATE = subdirs
CONFIG += ordered

contains(EXTENSIONS,unity) {
    SUBDIRS += UnitySystemTray
}

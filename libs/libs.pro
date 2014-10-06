TEMPLATE = subdirs
CONFIG += ordered

contains(EXNTESIONS,unity) {
    SUBDIRS += UnitySystemTray
}

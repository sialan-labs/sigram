defineTest(buildClickPkg) {
    clickpkg.commands = @echo Building click package... && click build $$DESTDIR
    clickpkg.depends = $$DESTDIR/$$TARGET
    first.depends = $$first.depends clickpkg
    export(clickpkg.commands)
    export(clickpkg.depends)
    export(first.depends)
    QMAKE_EXTRA_TARGETS += first clickpkg
    export (QMAKE_EXTRA_TARGETS)
}

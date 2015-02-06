
/*! For Service creating, Do something like this:
 *
    extern "C" int mainService(int argc, char *argv[])
    {
        QCoreApplication app(argc, argv);

        TestServiceWriter writer;
        writer.start();

        return app.exec();
    }
 *
 */

#include "asemanandroidservice.h"

#include <QtGlobal>

#include <dlfcn.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

#include <jni.h>
#include <android/log.h>
#include <android/api-level.h>

// Global variables

static jclass m_applicationClass  = NULL;

extern "C" typedef int (*Main)(int, char **); //use the standard main method to start the application
static JavaVM *m_javaVM = NULL;
static Main m_main = NULL;
static void *m_mainLibraryHnd = NULL;

static const char m_classErrorMsg[] = "Can't find class \"%s\"";
static const char m_methodErrorMsg[] = "Can't find method \"%s%s\"";

static void *startMainMethod(void *ar)
{
    Q_UNUSED(ar)
    __android_log_print(ANDROID_LOG_INFO, "Qt", "Calling main method");

    char *argv[] = { NULL};
    int argc = sizeof(argv) / sizeof(char*) - 1;

    m_main(argc, argv);
    return NULL;
}

static jboolean startQtApplication(JNIEnv *env, jobject object, jstring paramsString, jstring environmentString)
{
    Q_UNUSED(object)
    const char *nativeEnvironmentString = (env)->GetStringUTFChars(environmentString, NULL); // C++
    const char *nativeParamsString = (env)->GetStringUTFChars(paramsString, NULL); // C++

    // Print info

    __android_log_print(ANDROID_LOG_FATAL, "Qt", "Starting the Qt service");

        char cwd[1024];
        if (getcwd(cwd, sizeof(cwd)) != NULL)
            __android_log_print(ANDROID_LOG_INFO, "Qt", "Current working dir : %s", cwd);

        __android_log_print(ANDROID_LOG_FATAL, "Qt", "Param : %s", nativeParamsString );
        __android_log_print(ANDROID_LOG_FATAL, "Qt", "Env : %s", nativeEnvironmentString );

    // Start

    m_mainLibraryHnd = NULL;

    // Obtain a handle to the main library (the library that contains the main() function).
    // This library should already be loaded, and calling dlopen() will just return a reference to it.
    __android_log_print(ANDROID_LOG_INFO, "Qt", "Trying to open %s", nativeParamsString);
    m_mainLibraryHnd = dlopen(nativeParamsString, 0);

    if (m_mainLibraryHnd == NULL) {

        __android_log_print(ANDROID_LOG_INFO, "Qt", "No main library was specified; searching entire process (this is slow!)");
        m_main = (Main)dlsym(RTLD_DEFAULT, "mainService");
    }
    else {

        __android_log_print(ANDROID_LOG_INFO, "Qt", "Getting the main method from handler");
        m_main = (Main)dlsym(m_mainLibraryHnd, "mainService");
    }


    if (!m_main) {

        __android_log_print(ANDROID_LOG_INFO, "Qt", "Could not find main method");
        return 0;
    }
    else{

        __android_log_print(ANDROID_LOG_INFO, "Qt", "Main method found, starting");
    }


    pthread_t appThread;
    return pthread_create(&appThread, NULL, startMainMethod, NULL) == 0;
}

static JNINativeMethod methods[] = {
    {"startQtApplication", "(Ljava/lang/String;Ljava/lang/String;)V", (void *)startQtApplication},
};

#define FIND_AND_CHECK_CLASS(CLASS_NAME) \
clazz = env->FindClass(CLASS_NAME); \
if (!clazz) { \
    __android_log_print(ANDROID_LOG_FATAL, "Qt", m_classErrorMsg, CLASS_NAME); \
    return JNI_FALSE; \
}

jint JNICALL JNI_OnLoad(JavaVM *vm, void *ld)
{
    Q_UNUSED(ld)
    __android_log_print(ANDROID_LOG_INFO, "Qt", "Qt Android service wrapper start");

    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        __android_log_print(ANDROID_LOG_FATAL, "Qt", "Can't get env in wrapper start"); \
        return -1;
    }

    m_javaVM = vm;

    jclass clazz;
    FIND_AND_CHECK_CLASS("land/aseman/android/AsemanServiceDelegate");
    m_applicationClass = static_cast<jclass>(env->NewGlobalRef(clazz));

    __android_log_print(ANDROID_LOG_INFO, "Qt", "Registering native classes for service wrapper");

    if (env->RegisterNatives(m_applicationClass, methods, sizeof(methods) / sizeof(methods[0])) < 0) {
        __android_log_print(ANDROID_LOG_FATAL,"Qt", "RegisterNatives failed for service wrapper");
        return JNI_FALSE;
    }

    return JNI_VERSION_1_4;
}

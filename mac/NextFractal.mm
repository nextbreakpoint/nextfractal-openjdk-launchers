#include <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <jni.h>
#include <dlfcn.h>
#include <dirent.h>
#include <stdexcept>
#include <iostream>

extern "C" {
  // JNIEXPORT int JNICALL
  // JLI_Launch(int argc, char ** argv,              /* main argc, argc */
  //         int jargc, const char** jargv,          /* java args */
  //         int appclassc, const char** appclassv,  /* app classpath */
  //         const char* fullversion,                /* full version defined */
  //         const char* dotversion,                 /* dot version defined */
  //         const char* pname,                      /* program name */
  //         const char* lname,                      /* launcher name */
  //         jboolean javaargs,                      /* JAVA_ARGS */
  //         jboolean cpwildcard,                    /* classpath wildcard */
  //         jboolean javaw,                         /* windows-only javaw */
  //         jint     ergo_class                     /* ergnomics policy */
  // );
}

typedef jint (JNICALL *JNICreateJavaVM)(JavaVM **pvm, JNIEnv **env, void *args);

static void ShowAlert(const std::string message, const std::runtime_error& error) {
    std::string alertMessage = std::string(message).append("\n\nCause: ").append(error.what());
    CFStringRef cfTitle = CFStringCreateWithCString(NULL, "Something went wrong...", kCFStringEncodingUTF8);
    CFStringRef cfMessage = CFStringCreateWithCString(NULL, alertMessage.c_str(), kCFStringEncodingUTF8);
    CFUserNotificationDisplayNotice(0, kCFUserNotificationStopAlertLevel, NULL, NULL, NULL, cfTitle, cfMessage, NULL);
    CFRelease(cfTitle);
    CFRelease(cfMessage);
}

static std::string GetExePath() {
    return std::string([[[[NSBundle mainBundle] executablePath] stringByResolvingSymlinksInPath] UTF8String]);
}

static std::string GetBasePath(std::string exePath) {
    return exePath.substr(0, exePath.find_last_of("/"));
}

struct start_args {
    JavaVMInitArgs vm_args;

    start_args() {
    }

    start_args(const char **args) {
        vm_args.options = 0;
        vm_args.nOptions = 0;

        int arg_count = 0;
        const char **atarg = args;
        while (*atarg++) arg_count++;

        JavaVMOption *options = new JavaVMOption[arg_count];
        vm_args.nOptions = arg_count;
        for (int i = 0; i < vm_args.nOptions; i++)
            options[i].optionString = 0;
        vm_args.options = options;

        while (*args) {
            options->optionString = strdup(*args);
            options++;
            args++;
        }
        vm_args.version = JNI_VERSION_10;
        vm_args.ignoreUnrecognized = JNI_FALSE;
    }

    ~start_args() {
        for (int i = 0; i < vm_args.nOptions; i++)
            if (vm_args.options[i].optionString)
                free(vm_args.options[i].optionString);
        if (vm_args.options)
            delete[] vm_args.options;
    }

    start_args(const start_args &rhs) {
        vm_args.options = 0;

        vm_args.options = new JavaVMOption[rhs.vm_args.nOptions];
        vm_args.nOptions = rhs.vm_args.nOptions;
        for (int i = 0; i < vm_args.nOptions; i++) {
            vm_args.options[i].optionString = strdup(rhs.vm_args.options[i].optionString);
        }
        vm_args.version = rhs.vm_args.version;
        vm_args.ignoreUnrecognized = rhs.vm_args.ignoreUnrecognized;
    }

    start_args &operator=(const start_args &rhs) {
        for (int i = 0; i < vm_args.nOptions; i++) {
            if (vm_args.options[i].optionString) free(vm_args.options[i].optionString);
        }
        delete[] vm_args.options;

        vm_args.options = new JavaVMOption[rhs.vm_args.nOptions];
        vm_args.nOptions = rhs.vm_args.nOptions;
        for (int i = 0; i < vm_args.nOptions; i++)
            vm_args.options[i].optionString = 0;
        for (int i = 0; i < vm_args.nOptions; i++)
            vm_args.options[i].optionString = strdup(rhs.vm_args.options[i].optionString);
        vm_args.version = rhs.vm_args.version;
        vm_args.ignoreUnrecognized = rhs.vm_args.ignoreUnrecognized;
        return *this;
    }
};

struct launch_args {
  struct start_args *java_args;
  char *launch_class;
  char *java_home;

  launch_args() {
    launch_class = NULL;
    java_home = NULL;
    java_args = NULL;
  }

  launch_args(const char *javahome, const char *classname, const char ** vm_arglist) {
      launch_class = strdup(classname);
      java_home = javahome != NULL ? strdup(javahome) : NULL;
      java_args = new start_args(vm_arglist);
  }

  ~launch_args() {
      if (launch_class)
          free(launch_class);
      if (java_home)
          free(java_home);
      if (java_args)
          free(java_args);
  }
};

// typedef int (JNICALL * JNICreateJavaVM)(JavaVM** jvm, JNIEnv** env, JavaVMInitArgs* initargs);

void launch_java(JNICreateJavaVM createJavaVM, const char *launch_class, struct start_args *args) {
    JavaVM *jvm;
    JNIEnv *env;

    std::cout << "JVM arguments:" << std::endl;
    for (int i = 0; i < args->vm_args.nOptions; i++) {
        std::cout << args->vm_args.options[i].optionString << std::endl;
    }

    int res = createJavaVM(&jvm, &env, &args->vm_args);
    if (res < 0) {
        throw std::runtime_error("Cannot create JVM");
    }

    jclass main_class = env->FindClass(launch_class);
    if (main_class == NULL) {
        jvm->DestroyJavaVM();

        throw std::runtime_error("Main class not found");
    }

    jmethodID main_method_id = env->GetStaticMethodID(main_class, "main", "([Ljava/lang/String;)V");
    if (main_method_id == NULL) {
        jvm->DestroyJavaVM();

        throw std::runtime_error("Method main not found");
    }

    jobject empty_args = env->NewObjectArray(0, env->FindClass("java/lang/String"), NULL);
    if (empty_args == NULL) {
      jvm->DestroyJavaVM();

      throw std::runtime_error("Cannot allocate arguments");
    }

    env->CallStaticVoidMethod(main_class, main_method_id, empty_args);

    jvm->DestroyJavaVM();
}

void run_java(struct launch_args *run_args) {
    std::string path = run_args->java_home;
    path.erase(remove(path.begin(), path.end(), '\"'), path.end());
    std::cout << "JDK path: " << path << std::endl;

    struct start_args *args = run_args->java_args;

    std::string libPath = path + "/lib/server/libjvm.dylib";
    std::cout << "Library path: " << libPath << std::endl;

    void* lib_handle = dlopen(libPath.c_str(), RTLD_LOCAL|RTLD_LAZY);
    if (!lib_handle) {
        std::string message = std::string("Cannot open library ").append(libPath);
        throw std::runtime_error(message);
    }

    JNICreateJavaVM createJavaVM = (JNICreateJavaVM)dlsym(lib_handle, "JNI_CreateJavaVM");
    if (!createJavaVM) {
        dlclose(lib_handle);

        throw std::runtime_error("Function JNI_CreateJavaVM not found");
    }

    try {
        launch_java(createJavaVM, run_args->launch_class, args);

        dlclose(lib_handle);
    } catch (const std::runtime_error& e) {
        dlclose(lib_handle);

        throw e;
    }
}

void * start_java(void *start_args) {
    struct launch_args *args = (struct launch_args *)start_args;

    try {
        run_java(args);
    } catch (const std::runtime_error& e) {
      ShowAlert("Some error occurred while creating the Java VM. See instruction on https://nextbreakpoint.com/nextfractal.html for help.", e);

      exit(-1);
    }

    return NULL;
}

int main(int argc, char **argv) {
    try {
        std::string memMaxArg = std::string();
        char * varMemMax = getenv("NEXTFRACTAL_MAX_MEMORY");
        int varMemMaxLen = varMemMax != NULL ? strlen(varMemMax) : 0;
        if (varMemMaxLen > 0) {
            memMaxArg.append("-Xmx");
            memMaxArg.append(std::to_string(std::stoi(varMemMax)));
            memMaxArg.append("m");
        } else {
            memMaxArg.append("-Xmx4g");
        }

        std::string execPath = GetExePath();
        std::cout << "Executable path: " << execPath << std::endl;

        std::string basePath = GetBasePath(execPath);
        std::string modulePathArg = "--module-path=" + basePath + "/jars";
        std::string libraryPathArg = "-Djava.library.path=" + basePath + "/libs";
        std::string addModulesArg = "--add-modules=ALL-MODULE-PATH";
        std::string locationArg = "-Dbrowser.location=" + basePath + "/../../../examples";
        std::string loggingArg = "-Djava.util.logging.config.class=com.nextbreakpoint.nextfractal.runtime.logging.LogConfig";
        std::string jdkPath = basePath + "/jdk";

        const char *vm_arglist[] = {
            modulePathArg.c_str(),
            addModulesArg.c_str(),
            libraryPathArg.c_str(),
            locationArg.c_str(),
            loggingArg.c_str(),
            memMaxArg.c_str(),
            0
        };

        struct launch_args args(jdkPath.c_str(), "com/nextbreakpoint/nextfractal/runtime/javafx/NextFractalApp", vm_arglist);

        pthread_t thr;
        pthread_create(&thr, NULL, start_java, &args);

        CFRunLoopRun();
    } catch (const std::runtime_error& e) {
        ShowAlert("Some error occurred while launching the application. See instruction on https://nextbreakpoint.com/nextfractal.html for help.", e);

        exit(-1);
    }

    return 0;
}

// int main(int argc, char **argv) {
//     try {
//         std::string execPath = GetExePath();
//         std::cout << "Executable path: " << execPath << std::endl;
//
//         std::string basePath = GetBasePath(execPath);
//         std::string libraryPathArg = "-Djava.library.path=" + basePath + "/../../libs";
//         std::string locationArg = "-Dbrowser.location=" + basePath + "/../../../../../examples";
//         std::string loggingArg = "-Djava.util.logging.config.class=com.nextbreakpoint.nextfractal.runtime.logging.LogConfig";
//         std::string modulePathArg = basePath + "/../../jars";
//         std::string mainClassArg = "com.nextbreakpoint.nextfractal.runtime.javafx.NextFractalApp";
//
//         std::string memMaxArg = std::string();
//         char * varMemMax = getenv("NEXTFRACTAL_MAX_MEMORY");
//         int varMemMaxLen = varMemMax != NULL ? strlen(varMemMax) : 0;
//         if (varMemMaxLen > 0) {
//             memMaxArg.append("-Xmx");
//             memMaxArg.append(std::to_string(std::stoi(varMemMax)));
//             memMaxArg.append("m");
//         } else {
//             memMaxArg.append("-Xmx4g");
//         }
//
//         int jargc = 9;
//         const char *jargv[] = {
//             "--module-path",
//             modulePathArg.c_str(),
//             "--add-modules",
//             "ALL-MODULE-PATH",
//             loggingArg.c_str(),
//             libraryPathArg.c_str(),
//             locationArg.c_str(),
//             memMaxArg.c_str(),
//             mainClassArg.c_str()
//         };
//
//         std::cout << "JVM arguments:" << std::endl;
//         for (int i = 0; i < jargc; i++) {
//             std::cout << jargv[i] << std::endl;
//         }
//
//         JLI_Launch(0, argv, jargc, jargv, 0, NULL, "2.0.3", "0.0", argv[0], argv[0], jargc > 0, JNI_FALSE, JNI_FALSE, 0);
//     } catch (const std::runtime_error& e) {
//         ShowAlert("Some error occurred while launching the application. See instruction on https://nextbreakpoint.com/nextfractal.html for help.", e);
//
//         exit(-1);
//     }
//
//     return 0;
// }

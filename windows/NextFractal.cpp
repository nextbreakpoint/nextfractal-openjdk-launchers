#include <windows.h>
#include <jni.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <stdexcept>
#include <iostream>
#include <regex>

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

typedef int (JNICALL * JNICreateJavaVM)(JavaVM** jvm, JNIEnv** env, JavaVMInitArgs* initargs);

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

void ShowAlert(const std::string message, const std::runtime_error& error) {
    std::string alertMessage = std::string(message).append("\n\nCause: ").append(error.what());
    MessageBox(NULL, (LPCSTR)alertMessage.c_str(), (LPCSTR)"Something went wrong...", MB_ICONERROR | MB_OK | MB_DEFBUTTON2);
}

void run_java(struct launch_args *run_args) {
    std::string path = run_args->java_home;
    path.erase(remove(path.begin(), path.end(), '\"'), path.end());
    std::cout << "JDK path: " << path << std::endl;

    struct start_args *args = run_args->java_args;

    std::string libPath = path + "\\bin\\server\\jvm.dll";
    std::cout << "Library path: " << libPath << std::endl;

    HMODULE jniModule = LoadLibrary(libPath.c_str());
    if (NULL == jniModule) {
        std::string message = std::string("Cannot open library ").append(libPath);
        throw std::runtime_error(message);
    }

    JNICreateJavaVM createJavaVM = (JNICreateJavaVM)GetProcAddress(jniModule, "JNI_CreateJavaVM");
    if (NULL == createJavaVM) {
        FreeLibrary(jniModule);

        throw std::runtime_error("Function JNI_CreateJavaVM not found");
    }

    try {
        launch_java(createJavaVM, run_args->launch_class, args);

        FreeLibrary(jniModule);
    } catch (const std::runtime_error& e) {
        FreeLibrary(jniModule);

        throw e;
    }
}

void * start_java(void *start_args) {
    struct launch_args *args = (struct launch_args *)start_args;

    try {
        run_java(args);
    } catch (const std::runtime_error& e) {
      ShowAlert("Some error occurred while creating Java VM. See instruction on https://nextbreakpoint.com/nextfractal.html for help.", e);

      exit(-1);
    }

    return NULL;
}

std::string GetExePath() {
  char buffer[MAX_PATH];
  GetModuleFileName(NULL, buffer, MAX_PATH);
  return std::string(buffer);
}

std::string GetBasePath(std::string exePath) {
    return exePath.substr(0, exePath.find_last_of("\\"));
}

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow) {
    FreeConsole();

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
        std::string modulePathArg = "--module-path=" + basePath + "\\jars";
        std::string libraryPathArg = "-Djava.library.path=" + basePath + "\\libs";
        std::string addModulesArg = "--add-modules=ALL-MODULE-PATH";
        std::string locationArg = "-Dbrowser.location=" + basePath + "\\examples";
        std::string loggingArg = "-Djava.util.logging.config.class=com.nextbreakpoint.nextfractal.runtime.logging.LogConfig";
        std::string jdkPath = basePath + "\\jdk";

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

        start_java((void *)&args);
    } catch (const std::runtime_error& e) {
        ShowAlert("Some error occurred while launching the application. See instruction on https://nextbreakpoint.com/nextfractal.html for help.", e);

        exit(-1);
    }

    return 0;
}

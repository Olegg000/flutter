#include <flutter/flutter_aurora.h>
#include "generated_plugin_registrant.h"
#include <flutter/flutter_compatibility_qt.h>

int main(int argc, char *argv[]) {
    aurora::EnableQtCompatibility();
    aurora::Initialize(argc, argv);
    aurora::RegisterPlugins();
    aurora::Launch();
    return 0;
}

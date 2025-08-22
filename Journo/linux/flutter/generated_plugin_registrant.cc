//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

<<<<<<< HEAD

void fl_register_plugins(FlPluginRegistry* registry) {
=======
#include <file_selector_linux/file_selector_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
>>>>>>> 6c676a37de101b535ebf0b395bb3e7da300ed52f
}

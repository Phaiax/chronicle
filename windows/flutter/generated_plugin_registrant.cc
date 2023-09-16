//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <mouse_event/mouse_event_plugin.h>
#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  MouseEventPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MouseEventPlugin"));
}

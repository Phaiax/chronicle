//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <hid_listener/hid_listener_plugin_windows.h>
#include <mouse_event/mouse_event_plugin.h>
#include <screen_capturer/screen_capturer_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  HidListenerPluginWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("HidListenerPluginWindows"));
  MouseEventPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MouseEventPlugin"));
  ScreenCapturerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenCapturerPlugin"));
}

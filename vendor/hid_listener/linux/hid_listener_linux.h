#pragma once
#include <stdint.h>
#include <hid_listener_shared.h>

enum LinuxKeyboardEventType
{
    LKE_KeyUp,
    LKE_KeyDown
};

struct LinuxKeyboardEvent {
    enum LinuxKeyboardEventType eventType;
    uint32_t unicodeScalarValues;
    uint32_t scanCode;
    uint32_t keyCode;
};

#if defined(__cplusplus)
extern "C"
{
#endif
    HID_LISTENER_FLUTTER_PLUGIN_EXPORT bool SetKeyboardListener(Dart_Port port);
    HID_LISTENER_FLUTTER_PLUGIN_EXPORT bool SetMouseListener(Dart_Port port);
    HID_LISTENER_FLUTTER_PLUGIN_EXPORT void InitializeDartAPI(void* data);
    HID_LISTENER_FLUTTER_PLUGIN_EXPORT bool InitializeListeners();
#if defined(__cplusplus)
}
#endif
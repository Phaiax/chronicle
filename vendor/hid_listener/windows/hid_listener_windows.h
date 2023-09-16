#pragma once
#include <stdint.h>
#include <hid_listener_shared.h>

enum WindowsKeyboardEventType
{
    WKE_KeyUp,
    WKE_KeyDown
};

struct WindowsKeyboardEvent {
    enum WindowsKeyboardEventType eventType;
    uint32_t vkCode;
    uint32_t scanCode;
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
#include "include/hid_listener/hid_listener_plugin_windows.h"

#include <hid_listener_windows.h>
#include <flutter/plugin_registrar_windows.h>
#include <dart-sdk/include/dart_native_api.h>
#include <dart-sdk/include/dart_api_dl.h>
#include <dart-sdk/include/dart_api_dl.c>

#include <functional>
#include "psapi.h"
#include "hid_listener_plugin.h"


static Dart_Port keyboardListenerPort = 0;
static Dart_Port mouseListenerPort = 0;

void NotifyDart(Dart_Port port, const void* work) {
	const intptr_t workAddr = reinterpret_cast<intptr_t>(work);

	Dart_CObject cObject;
	cObject.type = Dart_CObject_kInt64;
	cObject.value.as_int64 = workAddr;

	Dart_PostCObject_DL(port, &cObject);
}

static char* GetWindowTitle(HWND hwnd) {
    int length = GetWindowTextLength(hwnd);
    if (length == 0) {
        return "";
    }

    char* buffer = new char[length + 1];
    GetWindowTextA(hwnd, buffer, length + 1);
    return buffer;
}


static std::string GetPathFromWindowHandle(HWND hwnd) {
    DWORD processId;
    GetWindowThreadProcessId(hwnd, &processId);

    HANDLE processHandle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processId);
    if (!processHandle) {
        std::cerr << "Failed to open process." << std::endl;
        return "";
    }

    char executablePath[MAX_PATH];
    if (!GetModuleFileNameExA(processHandle, NULL, executablePath, sizeof(executablePath))) {
        std::cerr << "Failed to get module filename." << std::endl;
        CloseHandle(processHandle);
        return "";
    }

    CloseHandle(processHandle);
    return executablePath;
}

static void ExtendEventWithWindowInformation(MouseEvent& event) {
	HWND handle = GetForegroundWindow();
	event.windowTitle = GetWindowTitle(handle);
	// std::string activeWindowPath = GetPathFromWindowHandle(handle);
	// if (activeWindowPath.length() > 0) {
	// 	HICON hIcon = ExtractIconA(GetModuleHandle(NULL), activeWindowPath.c_str(), 0);
	// 	if (hIcon) {
	// 		// TODO
	// 		DestroyIcon(hIcon);
	// 	}
	// }
}


static LRESULT KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
	if (nCode < 0 || keyboardListenerPort == 0 || Dart_PostCObject_DL == nullptr) return CallNextHookEx(NULL, nCode, wParam, lParam);

	WindowsKeyboardEventType eventType = WindowsKeyboardEventType::WKE_KeyDown;

	if (wParam == WM_SYSKEYUP || wParam == WM_KEYUP) {
		eventType = WindowsKeyboardEventType::WKE_KeyUp;
	}

	KBDLLHOOKSTRUCT* info = reinterpret_cast<KBDLLHOOKSTRUCT*>(lParam);

	WindowsKeyboardEvent* keyboardEvent = new WindowsKeyboardEvent;
	keyboardEvent->eventType = eventType;
	keyboardEvent->vkCode = info->vkCode; 
	keyboardEvent->scanCode = info->scanCode;

	NotifyDart(keyboardListenerPort, keyboardEvent);

	return CallNextHookEx(NULL, nCode, wParam, lParam);
}

static LRESULT MouseProc(int nCode, WPARAM wParam, LPARAM lParam) {
	if (nCode < 0 || mouseListenerPort == 0 || Dart_PostCObject_DL == nullptr)
		return CallNextHookEx(NULL, nCode, wParam, lParam);

	MouseEventType eventType = MouseEventType::LeftButtonDown;

	if (wParam == WM_LBUTTONDOWN) {
		eventType = MouseEventType::LeftButtonDown;
	} else if (wParam == WM_LBUTTONUP) {
		eventType = MouseEventType::LeftButtonUp;
	} else if (wParam == WM_RBUTTONDOWN) {
		eventType = MouseEventType::RightButtonDown;
	} else if (wParam == WM_RBUTTONUP) {
		eventType = MouseEventType::RightButtonUp;
	} else if (wParam == WM_MOUSEMOVE) {
		eventType = MouseEventType::MouseMove;
	} else if (wParam == WM_MOUSEWHEEL) {
		eventType = MouseEventType::MouseWheel;
	} else if (wParam == WM_MOUSEHWHEEL) {
		eventType = MouseEventType::MouseHorizontalWheel;
	}

	MSLLHOOKSTRUCT* info = reinterpret_cast<MSLLHOOKSTRUCT*>(lParam);

	MouseEvent *mouseEvent = new MouseEvent;
	mouseEvent->eventType = eventType;
	mouseEvent->x = (double)info->pt.x;
	mouseEvent->y = (double)info->pt.y;
	mouseEvent->wheelDelta = HIWORD(info->mouseData);
	HWND handle = GetForegroundWindow();
	mouseEvent->windowTitle = GetWindowTitle(handle);

	NotifyDart(mouseListenerPort, mouseEvent);

	return CallNextHookEx(NULL, nCode, wParam, lParam);
}

#if defined(__cplusplus)

HidListener* HidListener::listenerInstance = nullptr;

HidListener::HidListener() {
    m_keyboardHook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, NULL, NULL);
	m_mouseHook = SetWindowsHookEx(WH_MOUSE_LL, MouseProc, NULL, NULL);

	listenerInstance = this;
}

HidListener::~HidListener() {
	UnhookWindowsHookEx(m_keyboardHook);
	UnhookWindowsHookEx(m_mouseHook);

	listenerInstance = nullptr;
}

#endif

bool SetKeyboardListener(Dart_Port port) {
	if(HidListener::Get() == nullptr) return false;
	keyboardListenerPort = port;
	return true;
}

bool SetMouseListener(Dart_Port port) {
	if(HidListener::Get() == nullptr) return false;
	mouseListenerPort = port;
	return true;
}

void InitializeDartAPI(void* data) {
	Dart_InitializeApiDL(data);
}

bool InitializeListeners() {
	return true;
}

void HidListenerPluginWindowsRegisterWithRegistrar(
	FlutterDesktopPluginRegistrarRef registrar) {
	hid_listener::HidListenerPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarManager::GetInstance()
		->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

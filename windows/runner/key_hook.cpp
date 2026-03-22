#include "key_hook.h"
#include <iostream>

KeyHook* KeyHook::instance_ = nullptr;

void KeyHook::Init(flutter::BinaryMessenger* messenger) {
  if (!instance_) {
    instance_ = new KeyHook();
    instance_->SetupChannel(messenger);
  }
}

KeyHook::KeyHook() {}

KeyHook::~KeyHook() {
  UninstallHook();
}

void KeyHook::SetupChannel(flutter::BinaryMessenger* messenger) {
  auto channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
      messenger, "strokeviz/keystrokes", &flutter::StandardMethodCodec::GetInstance());

  auto handler = std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
      [this](const flutter::EncodableValue* arguments,
             std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
        event_sink_ = std::move(events);
        InstallHook();
        return nullptr;
      },
      [this](const flutter::EncodableValue* arguments) {
        UninstallHook();
        event_sink_ = nullptr;
        return nullptr;
      });

  channel->SetStreamHandler(std::move(handler));
}

void KeyHook::InstallHook() {
  if (!hook_handle_) {
    hook_handle_ = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, GetModuleHandle(nullptr), 0);
  }
}

void KeyHook::UninstallHook() {
  if (hook_handle_) {
    UnhookWindowsHookEx(hook_handle_);
    hook_handle_ = nullptr;
  }
}

LRESULT CALLBACK KeyHook::KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode >= 0 && instance_ && instance_->event_sink_) {
    KBDLLHOOKSTRUCT* kbdStruct = (KBDLLHOOKSTRUCT*)lParam;
    
    flutter::EncodableMap event;
    event[flutter::EncodableValue("vkCode")] = flutter::EncodableValue((int)kbdStruct->vkCode);
    event[flutter::EncodableValue("scanCode")] = flutter::EncodableValue((int)kbdStruct->scanCode);
    event[flutter::EncodableValue("flags")] = flutter::EncodableValue((int)kbdStruct->flags);
    
    bool valid = false;
    if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) {
      event[flutter::EncodableValue("type")] = flutter::EncodableValue("keydown");
      valid = true;
    } else if (wParam == WM_KEYUP || wParam == WM_SYSKEYUP) {
      event[flutter::EncodableValue("type")] = flutter::EncodableValue("keyup");
      valid = true;
    }

    if (valid) {
      instance_->event_sink_->Success(flutter::EncodableValue(event));
    }
  }
  return CallNextHookEx(nullptr, nCode, wParam, lParam);
}

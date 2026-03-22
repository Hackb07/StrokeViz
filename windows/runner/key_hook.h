#ifndef RUNNER_KEY_HOOK_H_
#define RUNNER_KEY_HOOK_H_

#include <flutter/binary_messenger.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <memory>

class KeyHook {
 public:
  static void Init(flutter::BinaryMessenger* messenger);

 private:
  KeyHook();
  ~KeyHook();

  void SetupChannel(flutter::BinaryMessenger* messenger);
  void InstallHook();
  void UninstallHook();

  static LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);

  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
  HHOOK hook_handle_ = nullptr;
  static KeyHook* instance_;
};

#endif

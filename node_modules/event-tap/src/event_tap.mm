#import <node.h>
#import <v8.h>
#import <ApplicationServices/ApplicationServices.h>
#import <string>

using namespace v8;

CGEventType EventTypeFromString(std::string eventTypeString);
CGMouseButton MouseButtonFromString(std::string mouseButtonString);

Handle<Value> PostKeyboardEvent(const Arguments& args) {
  HandleScope scope;

  if (args.Length() == 0 || !args[0]->IsNumber()) {
    ThrowException(Exception::TypeError(String::New("You must pass an integer keycode")));
    return scope.Close(Undefined());
  }

  CGKeyCode keyCode = args[0]->NumberValue();

  bool keyDown = true;
  if (args.Length() > 1) {
    keyDown = args[1]->BooleanValue();
  }

  CGEventRef event = CGEventCreateKeyboardEvent(NULL, keyCode, keyDown);
  CGEventPost(kCGSessionEventTap, event);
  CFRelease(event);
  return scope.Close(Undefined());
}

Handle<Value> PostMouseEvent(const Arguments& args) {
  HandleScope scope;

  if (args.Length() < 3 || !args[0]->IsString() || !args[1]->IsNumber() || !args[2]->IsNumber()) {
    ThrowException(Exception::TypeError(String::New("You must pass an event type and a pair of integer X and Y coordinates")));
    return scope.Close(Undefined());
  }

  v8::String::Utf8Value eventTypeString(args[0]->ToString());
  CGEventType eventType = EventTypeFromString(std::string(*eventTypeString));
  if (eventType == kCGEventNull) {
    ThrowException(Exception::TypeError(String::Concat(String::New("Unrecognized event type: "), args[0]->ToString())));
    return scope.Close(Undefined());
  }

  CGPoint point;
  point.x = args[1]->NumberValue();
  point.y = args[2]->NumberValue();


  CGMouseButton mouseButton = kCGMouseButtonLeft;
  if (args.Length() > 3) {
    if (!args[3]->IsString()) {
      ThrowException(Exception::TypeError(String::New("If you supply an optional mouse button argument, it must be a string")));
      return scope.Close(Undefined());
    }

    v8::String::Utf8Value mouseButtonString(args[3]->ToString());
    CGMouseButton mouseButton = MouseButtonFromString(std::string(*mouseButtonString));

    if (mouseButton == 4) {
      ThrowException(Exception::TypeError(String::New("Mouse button not recognized (must be 'left', 'right', or 'center')")));
      return scope.Close(Undefined());
    }
  }

  CGEventRef event = CGEventCreateMouseEvent(NULL, eventType, point, mouseButton);
  CGEventPost(kCGHIDEventTap, event);

  CFRelease(event);
  return scope.Close(Undefined());
}

CGEventType EventTypeFromString(std::string eventTypeString) {
  if (eventTypeString == "leftMouseDown") return kCGEventLeftMouseDown;
  if (eventTypeString == "leftMouseUp") return kCGEventLeftMouseUp;
  if (eventTypeString == "rightMouseDown") return kCGEventRightMouseDown;
  if (eventTypeString == "rightMouseUp") return kCGEventRightMouseUp;
  if (eventTypeString == "mouseMoved") return kCGEventMouseMoved;
  if (eventTypeString == "leftMouseDragged") return kCGEventLeftMouseDragged;
  if (eventTypeString == "rightMouseDragged") return kCGEventRightMouseDragged;
  if (eventTypeString == "keyDown") return kCGEventKeyDown;
  if (eventTypeString == "keyUp") return kCGEventKeyUp;
  if (eventTypeString == "flagsChanged") return kCGEventFlagsChanged;
  if (eventTypeString == "scrollWheel") return kCGEventScrollWheel;
  if (eventTypeString == "tabletPointer") return kCGEventTabletPointer;
  if (eventTypeString == "tabletProximity") return kCGEventTabletProximity;
  if (eventTypeString == "otherMouseDown") return kCGEventOtherMouseDown;
  if (eventTypeString == "otherMouseUp") return kCGEventOtherMouseUp;
  if (eventTypeString == "otherMouseDragged") return kCGEventOtherMouseDragged;
  if (eventTypeString == "disabledByTimeout") return kCGEventTapDisabledByTimeout;
  if (eventTypeString == "disabledByUserInput") return kCGEventTapDisabledByUserInput;
  return kCGEventNull;
}

CGMouseButton MouseButtonFromString(std::string mouseButtonString) {
  if (mouseButtonString == "left") return kCGMouseButtonLeft;
  if (mouseButtonString == "right") return kCGMouseButtonRight;
  if (mouseButtonString == "center") return kCGMouseButtonCenter;
  return 4;
}

Handle<Value> GetMouseLocation(const Arguments& args) {
  HandleScope scope;
  CGEventRef  event;
  CGPoint point;
  Local<Object> coordinates;

  coordinates = Object::New();
  event = CGEventCreate(NULL);
  point = CGEventGetLocation(event);

  coordinates->Set(String::NewSymbol("x"), Integer::New(point.x));
  coordinates->Set(String::NewSymbol("y"), Integer::New(point.y));

  CFRelease(event);
  return scope.Close(coordinates);
}

void Init(Handle<Object> target) {
  target->Set(String::NewSymbol("postKeyboardEvent"), FunctionTemplate::New(PostKeyboardEvent)->GetFunction());
  target->Set(String::NewSymbol("postMouseEvent"), FunctionTemplate::New(PostMouseEvent)->GetFunction());
  target->Set(String::NewSymbol("getMouseLocation"), FunctionTemplate::New(GetMouseLocation)->GetFunction());
}

NODE_MODULE(event_tap, Init)

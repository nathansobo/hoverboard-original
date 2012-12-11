#import <node.h>
#import <v8.h>
#import <ApplicationServices/ApplicationServices.h>

using namespace v8;

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
  CGPoint point;

  if (args.Length() < 2 || !args[0]->IsNumber() || !args[1]->IsNumber()) {
    ThrowException(Exception::TypeError(String::New("You must pass a pair of integer X and Y coordinates")));
    return scope.Close(Undefined());
  }

  point.x = args[0]->NumberValue();
  point.y = args[1]->NumberValue();

  CGEventRef event = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);
  CGEventPost(kCGHIDEventTap, event);

  CFRelease(event);
  return scope.Close(Undefined());
}

void Init(Handle<Object> target) {
  target->Set(String::NewSymbol("postKeyboardEvent"), FunctionTemplate::New(PostKeyboardEvent)->GetFunction());
  target->Set(String::NewSymbol("postMouseEvent"), FunctionTemplate::New(PostMouseEvent)->GetFunction());
}

NODE_MODULE(event_tap, Init)

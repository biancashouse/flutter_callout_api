import 'dart:collection';

class CPIReasonStack {
  static final CPIReasonStack instance = CPIReasonStack._(Queue<String>());
  Queue<String> queue;

  // private, named constructor
  CPIReasonStack._(this.queue);

  factory CPIReasonStack.singleton() => instance;

  void push(String theReason) => queue.addFirst(theReason);
  String pop() => queue.removeFirst();
  int get length => queue.length;
}
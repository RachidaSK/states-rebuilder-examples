class TimerModel {
  TimerModel(this.initialTime);

  int initialTime;

  getTimerStream() {
    return Stream.periodic(
      Duration(seconds: 1),
      (num) => num,
    );
  }
}

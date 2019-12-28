class CourseRegistrationRequestMessage {
  final int studentId;
  final List<String> selectedCourseCodes;

  CourseRegistrationRequestMessage({this.studentId, this.selectedCourseCodes});
}

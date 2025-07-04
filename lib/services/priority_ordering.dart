String getPriorityLabel(int value) {
  switch (value) {
    case 1:
      return 'High';
    case 2:
      return 'Medium';
    case 3:
    default:
      return 'Low';
  }
}

int getPriorityValue(String label) {
  switch (label) {
    case 'High':
      return 1;
    case 'Medium':
      return 2;
    case 'Low':
    default:
      return 3;
  }
}

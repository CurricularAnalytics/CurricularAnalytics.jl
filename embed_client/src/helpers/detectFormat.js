export default function (curriculum) {
  if (curriculum.courses) {
    return 'basic'
  } else if (curriculum.curriculum_terms) {
    return 'verbose'
  } else {
    return 'default'
  }
}

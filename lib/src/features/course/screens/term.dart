// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shadcn_flutter/shadcn_flutter.dart';
// import '../providers/course_provider.dart';

// class CourseDetailScreen extends ConsumerWidget {
//   final String courseId;

//   const CourseDetailScreen({super.key, required this.courseId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final courseAsync = ref.watch(selectedCourseProvider);

//     return Container(
//       color: Colors.neutral[300],
//       child: courseAsync.when(
//         data: (course) {
//           if (course == null)
//             return const Center(child: Text('Course not found'));

//           return Column(
//             children: [
//               // Back button
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: IconButton.primary(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.arrow_back),
//                   ),
//                 ),
//               ),

//               // Course content
//               Expanded(
//                 child: CustomScrollView(
//                   slivers: [
//                     SliverToBoxAdapter(
//                       child: AspectRatio(
//                         aspectRatio: 16 / 9,
//                         child: Image(
//                           image: NetworkImage(course.thumbnail),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: const EdgeInsets.all(16),
//                       sliver: SliverList(
//                         delegate: SliverChildListDelegate([
//                           Text(
//                             course.title,
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(course.description),
//                           if (course.isEnrolled) ...[
//                             const SizedBox(height: 16),
//                             LinearProgressIndicator(
//                               value: course.progress / 100,
//                             ),
//                             Text('${course.progress.toInt()}% Complete'),
//                           ],
//                         ]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Enroll button
//               if (!course.isEnrolled)
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.red[400],
//                     border: Border(top: BorderSide(color: Colors.black)),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: DestructiveButton(
//                           onPressed: () {
//                             // Handle enrollment
//                           },
//                           child: const Text('Enroll Now'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }

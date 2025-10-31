// import 'package:flutter/widgets.dart';
// import '../screens/course_list_screen.dart';
// import '../screens/course_detail_screen.dart';

// Route<dynamic> generateRoute(RouteSettings settings) {
//   // Extract route name and parameters
//   if (settings.name?.startsWith('/course/') ?? false) {
//     final courseId = settings.name!.split('/').last;
    
//     return PageRouteBuilder(
//       settings: settings,
//       pageBuilder: (context, animation, secondaryAnimation) => 
//         CourseDetailScreen(courseId: courseId),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(begin: begin, end: end)
//             .chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//         return SlideTransition(position: offsetAnimation, child: child);
//       },
//     );
//   }
  
//   // Default route for home
//   if (settings.name == '/' || settings.name == null) {
//     return PageRouteBuilder(
//       settings: settings,
//       pageBuilder: (context, animation, secondaryAnimation) => 
//         const CourseListScreen(),
//     );
//   }

//   // Handle unknown routes
//   return PageRouteBuilder(
//     settings: settings,
//     pageBuilder: (context, animation, secondaryAnimation) => 
//       const CourseListScreen(),
//   );
// }
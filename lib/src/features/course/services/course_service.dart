import '../models/course.dart';

class CourseService {
  Future<List<Course>> getCourses({int page = 1}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(
      10,
      (index) => Course(
        id: '${page}_$index',
        title: 'Flutter Development Course ${page}_$index',
        instructor: 'John Doe',
        thumbnail: 'https://picsum.photos/200/300',
        price: 99.99,
        rating: 4.5,
        category: ['Development', 'Design', 'Business'][index % 3],
        duration: '${(index + 1) * 2}h',
        description: 'Learn Flutter development from scratch...',
      ),
    );
  }

  Future<Course> getCourseById(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return Course(
      id: id,
      title: 'Flutter Development Course $id',
      instructor: 'John Doe',
      thumbnail: 'https://picsum.photos/200/300',
      price: 99.99,
      rating: 4.5,
      category: 'Development',
      duration: '24h',
      description: 'Learn Flutter development from scratch with this comprehensive course...',
    );
  }
}
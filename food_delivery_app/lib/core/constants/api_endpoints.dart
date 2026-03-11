class ApiEndpoints {
  // LƯU Ý QUAN TRỌNG: 
  // Nếu chạy trên máy ảo Android, phải dùng 10.0.2.2 thay vì localhost
  // Nếu chạy trên máy thật, thay bằng IP LAN của máy tính (VD: 192.168.1.x)
  static const String baseUrl = 'http://192.168.1.198/DoAn_FoodDelivery/api';
  
  static const String login = '$baseUrl/login.php';
  static const String register = '$baseUrl/register.php'; // Chuẩn bị cho Sprint sau
}
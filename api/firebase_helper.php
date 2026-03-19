<?php
require_once 'vendor/autoload.php'; // Load thư viện Google Auth

use Google\Auth\Credentials\ServiceAccountCredentials;
use Google\Auth\HttpHandler\HttpHandlerFactory;

class FirebaseHelper {
    // Thay bằng Project ID thật của bạn (lấy trong file JSON: project_id)
    private static $project_id = 'epicuredelivery'; 

    public static function sendNotification($fcm_token, $title, $message) {
        $json_path = __DIR__ . '/service-account.json';
        $scopes = ['https://www.googleapis.com/auth/cloud-platform'];

        // 1. Tạo Access Token từ file Service Account
        $credentials = new ServiceAccountCredentials($scopes, $json_path);
        $token_array = $credentials->fetchAuthToken(HttpHandlerFactory::build());
        $access_token = $token_array['access_token'];

        // 2. Cấu trúc Payload của FCM V1 (Khác hoàn toàn bản cũ)
        $url = "https://fcm.googleapis.com/v1/projects/" . self::$project_id . "/messages:send";
        
        $payload = [
            'message' => [
                'token' => $fcm_token,
                'notification' => [
                    'title' => $title,
                    'body' => $message
                ],
                'android' => [
                    'priority' => 'high',
                    'notification' => [
                        'sound' => 'default',
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
                    ]
                ]
            ]
        ];

        // 3. Gửi Request bằng cURL
        $headers = [
            'Authorization: Bearer ' . $access_token,
            'Content-Type: application/json'
        ];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        $result = curl_exec($ch);
        curl_close($ch);
        
        return $result;
    } 
}
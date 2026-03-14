<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET': // Lấy danh sách
        $user_id = $_GET['user_id'];
        $sql = "SELECT * FROM user_addresses WHERE user_id = $user_id ORDER BY is_default DESC, id DESC";
        $result = $conn->query($sql);
        $data = [];
        while($row = $result->fetch_assoc()) { $data[] = $row; }
        echo json_encode(["status" => "success", "data" => $data]);
        break;

    case 'POST': // Thêm mới
        $data = json_decode(file_get_contents("php://input"));
        $u_id = $data->user_id;
        $title = $conn->real_escape_string($data->title);
        $detail = $conn->real_escape_string($data->address_detail);
        
        $sql = "INSERT INTO user_addresses (user_id, title, address_detail) VALUES ($u_id, '$title', '$detail')";
        if($conn->query($sql)) echo json_encode(["status" => "success"]);
        else echo json_encode(["status" => "error", "message" => $conn->error]);
        break;

    case 'DELETE': // Xóa
        $id = $_GET['id'];
        $conn->query("DELETE FROM user_addresses WHERE id = $id");
        echo json_encode(["status" => "success"]);
        break;
}
$conn->close();
?>
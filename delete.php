<?php
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);
$response = array();

if(isset($data['filename'])) {
    $file = "did_img/" . basename($data['filename']);
    
    if(file_exists($file)) {
        if(unlink($file)) {
            $response["success"] = true;
            $response["message"] = "파일이 삭제되었습니다.";
        } else {
            $response["success"] = false;
            $response["message"] = "파일 삭제 중 오류가 발생했습니다.";
        }
    } else {
        $response["success"] = false;
        $response["message"] = "파일을 찾을 수 없습니다.";
    }
} else {
    $response["success"] = false;
    $response["message"] = "파일명이 전달되지 않았습니다.";
}

echo json_encode($response);
?> 
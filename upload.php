<?php
header('Content-Type: application/json');

$target_dir = "did_img/";
$response = array();

if(isset($_FILES["image"])) {
    $target_file = $target_dir . basename($_FILES["image"]["name"]);
    
    // 이미지 파일 검증
    $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
    if($imageFileType != "jpg" && $imageFileType != "jpeg" && $imageFileType != "png" && $imageFileType != "gif") {
        $response["success"] = false;
        $response["message"] = "JPG, JPEG, PNG & GIF 파일만 업로드 가능합니다.";
        die(json_encode($response));
    }

    if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
        $response["success"] = true;
        $response["message"] = "파일이 업로드되었습니다.";
    } else {
        $response["success"] = false;
        $response["message"] = "업로드 중 오류가 발생했습니다.";
    }
} else {
    $response["success"] = false;
    $response["message"] = "파일이 선택되지 않았습니다.";
}

echo json_encode($response);
?> 
<?php
$conn = new mysqli('localhost', 'root', '', 'monitoring_api');
if ($conn->connect_error) {
    die('Connection failed: ' . $conn->connect_error);
}

$result = $conn->query('DESCRIBE user');
echo "Kolom di tabel user:\n";
while ($row = $result->fetch_assoc()) {
    echo '- ' . $row['Field'] . ' (' . $row['Type'] . ')' . "\n";
}
$conn->close();
?>

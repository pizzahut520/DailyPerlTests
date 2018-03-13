use File::stat;
  
$file = "c:\\temp\\46535.txt";  
  
$file_size = stat($file)->size;  

print $file_size;

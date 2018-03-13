use File::Path;


$dir = "c:\\temp\\testrmtree";
if (chdir("c:\\temp")) {
    rmtree("$dir", {keep_root=>1});   
}else{
  print "error";
}
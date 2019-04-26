BEGIN{
file=ARGV[1]
count=10
print file
while (getline a[++c] < file >0 ) 
{ 
 b=b a[c] ;
 if ( c %  count == 0) {
  system("echo " b" >abc&")
  #print b c
 b=""
 } 
}
}

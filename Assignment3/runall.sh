#!/bin/sh

echo "Running Assignment 3 XPath/XQuery Solutions" > results.txt
echo "" >> results.txt

for query in q1 q2 q3 q4 q5
do
   echo "============================== Query" $query " ==============================" >> results.txt
   echo "" >> results.txt

   # Determine what the right command-line argument(s) are to define the external
   # datasets this query will need.
   if [ "$query" = "q1" ]; then
      args="-doc dataset0=posting.xml"
   fi
   if [ "$query" = "q2" ]; then
      args="-doc dataset0=posting.xml"
   fi
   if [ "$query" = "q3" ]; then
      args="-doc dataset0=resume.xml"
   fi
   if [ "$query" = "q4" ]; then
      args="-doc dataset0=interview.xml -doc dataset1=resume.xml"
   fi
   if [ "$query" = "q5" ]; then
      args="-doc dataset0=posting.xml -doc dataset1=resume.xml"
   fi


   # First run the query without any xmllinting.  
   # Even ill-formed xml work work here.
   echo "------ raw output ------" >> results.txt
   echo "" >> results.txt
   galax-run $args $query.xq >> results.txt 2>&1
   echo "" >> results.txt

   # Now run the queries and produce formatted output using xmllint.  
   # Only well-formed xml will work here.
   echo "------ formatted output (therefore well-formed) ------" >> results.txt
   echo "" >> results.txt
   echo "<?xml version='1.0' standalone='no' ?>" > TEMP.xml
   galax-run $args $query.xq >> TEMP.xml  2>&1
   xmllint --format TEMP.xml >> results.txt  2>&1
   echo "" >> results.txt

   # Now validate the output of the queries.
   echo "------ checking validity of output ------" >> results.txt
   echo "" >> results.txt
   echo "<?xml version='1.0' standalone='no' ?>" > TEMP.xml
   echo -n "<!DOCTYPE " >> TEMP.xml
   # Put the right doctype in, which depends on the query.
   if [ "$query" = "q1" ]; then
      echo -n "dbjobs" >> TEMP.xml
   fi
   if [ "$query" = "q2" ]; then
      echo -n "important" >> TEMP.xml
   fi
   if [ "$query" = "q3" ]; then
      echo -n "qualified" >> TEMP.xml
   fi
   if [ "$query" = "q4" ]; then
      echo -n "bestskills" >> TEMP.xml
   fi
   if [ "$query" = "q5" ]; then
      echo -n "histogram" >> TEMP.xml
   fi
   echo " SYSTEM '"$query".dtd'>" >> TEMP.xml
   galax-run $args $query.xq >> TEMP.xml  2>&1
   echo "Are there any validity errors? (no news is good news)" >> results.txt
   xmllint --noout --valid TEMP.xml >> results.txt  2>&1
   echo "" >> results.txt
done

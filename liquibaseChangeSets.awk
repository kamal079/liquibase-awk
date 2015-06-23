# Copyright [2015] Kamal Ramakrishnan
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BEGIN{
	IGNORECASE=1;
	_lineStr = "";
	_SQLTriggerStarts = 0;
	_SQLTableStarts=0;
}
END{
}
{
	/* If you have multiple file names */
	if(FILENAME != _oldfilename)
	{
		 if (_oldfilename != "")
			  endfile(_oldfilename)
		 _oldfilename = FILENAME
		 beginfile(FILENAME)
	}
}
function beginfile(fileName)
{
	print "Extracting SQL triggers from " fileName;
}
function endfile(fileName){
 close (fileName);
}
END{
}
{
	if (_SQLTriggerStarts == 1 && $0 !~ /\//) {
		_lineStr = gensub(/(.*);/,"\\1","g",$0);
		print "\t\t" _lineStr;
	}
	if (_SQLTriggerStarts == 1 && $0 ~/\//) {
		_SQLTriggerStarts = 0;
		print "\t]]>\n\t</sql> \n </changeSet>";
	}

	if ($0 ~ /CREATE OR REPLACE TRIGGER/ && $0 !~ /--.*/) {
	  _SQLTriggerStarts = 1;
	  print "<changeSet id=\"" _changeSetName _liquibaseID "\" author=\"" _authorName "\">";
	  print "\t <sql splitStatements=\"true\" endDelimiter=\"_endDelimiter\" ><![CDATA[ \n";
	  print "\t\t" $0;
	  _liquibaseID ++;
	}
	if (_SQLTableStarts == 1 && $0 ~ /^\W*\)/){
		_SQLTableStarts = 0;
		print "\n</createTable> \n </changeSet>";
	}
	if (_SQLTableStarts == 1 && $0 !~ /^\)/)  {
		if ($0 ~ /.*\(.*\).*/) {
			 _lineStr = gensub(/([A-Z0-9_]+)\W*([A-Z0-9]+)\W*(\(.*\)).*/,"<column name=\"\\1\" type=\"\\2\\3\">" ,"g",$0);
		}
		else {
			 _lineStr = gensub(/([A-Z0-9_]+)\W*([A-Z0-9]+).*/,"<column name=\"\\1\" type=\"\\2\">" ,"g",$0);
		}
		if ($0 ~ /NOT NULL/) {
		    print _lineStr "\n\t<constraints nullable=\"false\"/>\n  </column>";
		} else {
		    print _lineStr "</column>";
		}
	}
	if ($0 ~ /CREATE TABLE/ && $0 !~ /--.*/) {
		_SQLTableStarts = 1;
		 print "<changeSet id=\"" _changeSetName _liquibaseID "\" author=\"" _authorName "\">";
		 _lineStr = gensub(/CREATE TABLE (.*)\.(.*)\W.*/,"<createTable schemaName=\"\\1\" tableName=\"\\2\">" ,"g",$0);
		print _lineStr;
		_liquibaseID ++;
	}
}

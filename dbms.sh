#!/bin/bash
#source dbms.sh || . dbms.sh
################################################################################
set usesdatabase=
usesdatabase=0 ##flag if there is database used
set useddatabase=
useddatabase=0 ##keep name of used database
################################################################################
#Just testing Fonts :D
function fontsdisplay(){
  clear
  figlist | while read font
  do
    toilet -f term -F border --gay "DBMS"
    banner " By"
    #figlet -f mono12 "   R&E"
    #toilet -f ivrit 'Linux is fun!' | boxes -d cat -a hc -p h8 | lolcat
    figlet -f $font  "   R&E"
    sleep 1
    clear
  done
  clear

  PS1=">>"
}
#End of function fontsdisplay
################################################################################
function showexists(){ ##Show tables|Databases
  echo "${arr[@]}"
  if [ "${arr[0]}" = "show" -a "${arr[1]}" = "databases" ]; then
    echo `ls `
  elif [ "${arr[0]}" = "show" -a "${arr[1]}" = "tables" ]; then
    if (( $usesdatabase !=0 )); then
      echo $useddatabase;
      ls -hx ./$useddatabase/*.t  | sed -e 's/\.t$//'
    else
      echo "Choose 'Use' Database First";
    fi
  else
    echo "Wrong Syntax!";
  fi
}
################################################################################
function useexists(){ ##use database dbname
  echo "${arr[@]}"
  if [ "${arr[0]}" = "use" ]; then
    if [ -d "${arr[1]}" ]; then
      let "usesdatabase=1";
      declare -g "useddatabase=${arr[1]}"; #declare this variable as global variable
      echo "$useddatabase";
    else
      echo "Database ${arr[1]} Not exist!";
    fi
  fi
}
################################################################################
function createnew(){ ##create table tblName | create database dbName
  echo "${arr[@]}"
  if [ "${arr[0]}" = "create" -a "${arr[1]}" = "table" ]; then
    if (( $usesdatabase !=0 )); then
      tableName="${arr[2]}"
      if [ -f ./$useddatabase/$tableName.m ]; then
        echo "Table already exists!";
        pp=1;
      else
        touch ./$useddatabase/$tableName.m #MetaData
        touch ./$useddatabase/$tableName.t #Data
        echo -e "Enter No. of Fields:";
        read -r nf;
        x=1;
        fields=""
        echo "You will be asked about field properties..."
        while [ $x -le $nf ]; do
          echo -e "Field $x's Name:";
          read -r fld;
          echo -e "Primary Key (y/n)?";
          read -r pk;
          echo -e "Foreign Key (y/n)?";
          read -r fk;
          if [ $pk = "y" ]; then
            uq="y";
            nn="y";
            df="n";
          else
            echo -e "Unique (y/n)?";
            read -r uq;
            if [ $uq = "y" ]; then
              nn="y";
              df="n";
            else
              echo -e "Not NULL (y/n)?";
              read -r nn;
              echo -e "Has Default Value (y/n)?";
              read -r df;
              if [ $df = "y" ]; then
                echo -e "Enter Default value:";
                read -r df;
              fi
            fi
          fi
          echo -e "Enter Data Type (int/char/mixed):";
          read -r dt;
          if [ $dt = "int" ]; then
            dt="int";
            echo -e "Has Check Condition (y/n)?";
            read -r ch;
            if [ $ch = "y" ]; then
              echo -e "Less than or greater than or equal [lt , gt , le, ge]:";
              read -r cons;
              echo -e "Enter Condition Value:"
              read -r cv;
              ch="$cons:$cv";
            fi
          elif [ $dt = "char" ]; then
            dt="char";
          else
            dt="mixed";
          fi
          rec=" ";
          rec="$fld::$pk::$fk::$nn::$uq::$df::$ch::$dt";
          if (( $x < $nf )); then
            fields="$fields$fld;";
          else
            fields="$fields$fld";
          fi

          echo "$rec" >> ./$useddatabase/$tableName.m ;
          x=`expr $x + 1`;
        done
        echo $fields > ./$useddatabase/$tableName.t
        echo -e "Table Created Successfully"
      fi
    else
      echo "Choose 'Use' Database First!";
    fi
  elif [ "${arr[0]}" = "create" -a "${arr[1]}" = "database" ]; then
    ##To Create new Database folder and then use it.
    echo "Creating new Database if not exist";
    if [ -d "${arr[2]}" ]; then
      echo "Database ${arr[2]} already exists!"
    else
      mkdir  "${arr[2]}";
    fi
  else
    echo "Syntax Error!";
  fi
}
################################################################################
function checkuniqe(){ ##check for unique data
  flag=0;
  nor=`awk 'BEGIN{i=0;} { i++; } END{print i;}' $1`;
  for (( x=1;x<=$nor;x++ ))
  do
    str1=`awk -F ";" -v r=$x -v f=$2 ' NR == r { print $f } ' $1`;
    for (( y=$x+1;y<=$nor;y++ ))
    do
      str2=`awk -F ";" -v r=$y -v f=$2 ' NR == r { print $f } ' $1`;
      if [ $str1 = $str2 ]; then
        flag=1;
        break;
      fi
      if [ $str1 = $3 ]; then
        flag=1;
        break;
      fi
      if [ $str2 = $3 ]; then
        flag=1;
        break;
      fi
    done
  done
  echo $flag;
}

function isnumeric(){ #check for integer number
	#result=$(echo "$1" | tr -d '[[:digit:]]')
  result=$(echo "$1" | grep -E ^\-?[0-9]+$)
	echo ${#result}
}

function isalpha(){ #check for characters only
	#result=$(echo "$1" | tr -d '[[:alpha:]]')
  result=$(echo "$1" | grep -E ^\-?[A-Za-z]+$)
	echo ${#result}
}

function isalnum(){ #check for mixed
	result=$(echo "$1" | tr -d '[[:alnum:]]')
	echo ${#result}
}

function insertrecord(){ ##insert into tblName
  echo "${arr[@]}"
  if [ ${arr[0]} = "insert" -a ${arr[1]} = "into" ]; then
    tn="./$useddatabase/${arr[2]}.t"
    tableName="./$useddatabase/${arr[2]}.m"
    if [ -f $tableName ]; then
      flagentry="y";
      nr=`awk 'BEGIN{i=0;} { i++; } END{print i;}' $tableName`; #Number of Rows in meta file as fields
      nf=`awk -F "::" ' NR == 1 {print NF}' $tableName`; #Number of Columns in meta file as properties of field
      x=1;
      while [ $x -le $nr ]
      do
        y=0;
        while [ $y -lt $nf ]
        do
          z=y;
          y=`expr $y + 1`;
          #Array of Constrains
          cons[z]=`awk -F "::" -v v1=$x -v v2=$y ' NR == v1  { printf("%s",$v2); }' $tableName`;
        done

        echo -e "${cons[1]}";
        read -r rec[$x];
        if [ ${cons[2]} = "y" ]; then
          echo -e "Note: You are inserting Primary Key Value";
          touch temp
          awk -F ";" 'NR != 1 {print $0;}' $tn > temp
          t=temp
          ret=$( checkuniqe $t $x ${rec[$x]} ); #Check Unique
          echo $ret
          #Check for Unique Primary Key
          if [ $( checkuniqe $tn $x ${rec[$x]} )  -eq 1 ]; then
            echo -e "Duplicate entry for Primary Key";
            flagentry="n";
            break;
          fi
        fi
        #check for Foreign Key
        if [ ${cons[3]} = "y" -a $flagentry != "n" ]; then
          echo -e "FK true"; # check with the other table
        fi
        #Chell for Nullable values
        if [ ${cons[4]} = "y"  -a $flagentry != "n" ]; then
          if [ ${rec[$x]} = "" ]; then
            echo -e "Attempt to insert NULL value";
            flagentry="n";
          fi
        fi
        #Check for Unique Values of Unique Field
        if [ ${cons[5]} = "y"  -a $flagentry != "n" ]; then
          ret=$( checkuniqe $tn $x ${rec[$x]} );
          if [ $ret -eq 1 ]; then
            echo -e "Duplicate entry for unique field";
            flagentry="n";
          fi
        fi
        #Check if having Default Value if Inserted Value is NULL, Insert Default Value
        if [ ${cons[6]} != "n" -a ${cons[4]} == "y"  -a $flagentry != "n" ]; then
          if [ ${rec[$x]} = "" ]; then
            echo -e "Default value inserted";
            ${rec[$x]}=${cons[6]};
          fi
        fi
        #Check For Condition on Field
        chk=`echo "${cons[7]}" | awk -F ":" ' { print $1 } '`;
        if [ $chk != "n" ]; then
          cv=`echo "${cons[7]}" | awk -F ":" ' { print $2 } '`;
          if [ ${rec[$x]} -$chk $cv ]; then
            echo "Valied with condition";
          else
            echo -e "Invalid FIELD Value, Check Condition";
          fi
        fi
        #Check For Data-Type
        dt=`echo "${cons[8]}" | awk -F ":" ' { print $1 } '`;
        if [ $dt == "int" ]; then
          echo "Check for Data Type of Int";
          if [[ $(isnumeric "${rec[$x]}") != '' ]]; then
            #if True ... OK
            echo "Valid Data Type of Integer"
          else
            echo -e "Invalid FIELD Data Type Not Int, Check Condition";
            flagentry="n";
          fi
        elif [ $dt == "char" ]; then
          echo "Check for Data Type of Char";
          if [[ $(isalpha "${rec[$x]}") != '' ]]; then
            #if True ... OK
            echo "Valid Data Type of Char"
          else
            echo -e "Invalid FIELD Data Type Not Char, Check Condition";
            flagentry="n";
          fi
        else
          echo "Check for Data Type of Mixed";
        fi
        x=`expr $x + 1`;
      done
      record="";
      for (( w=1;w<=$nr;w++ ))
      do
        if (( $w<$nr ))
        then
          record="$record${rec[$w]};";
        else
          record="$record${rec[$w]}";
        fi
      done
      if [ $flagentry != "n" ]; then
        echo "$record" | cat >> $tn;
        echo -e "Value inserted Successfully";
      else
        echo "Check Your constrains !"
      fi
    else
      echo -e "Table doesn't exists !";
    fi
  fi
}
################################################################################
function updaterecord(){ ##update table tblName set {CHANGES} || No Validation on new data
  echo "${arr[@]}"
  if [ "${arr[0]}"='update' -a "${arr[2]}"='set' -a "${arr[6]}"='where' ]
  then
    tn="./$useddatabase/${arr[1]}.t"
    tableName="./$useddatabase/${arr[1]}.m"
    var=`head -n 1 $tn`
    IFS=";" read -a fields <<< "$var";

    index=1;
    for f in "${fields[@]}"
      do
        if [ $f == "${arr[7]}" ]; then
          echo $f;
          echo $index;
          echo ${arr[7]};
          break;
        else
          echo $f
          index=`expr $index + 1`
          echo $index;
          echo ${arr[7]};
        fi
    done

    position=1;
    for p in "${fields[@]}"
      do
        if [ $p == "${arr[3]}" ]; then
          echo $p;
          echo $position;
          echo ${arr[3]};
          break;
        else
          echo $p
          position=`expr $position + 1`
          echo $position;
          echo ${arr[3]};
        fi
      done
      echo $position

      if [ -f temp ]
        then
          rm temp
      fi
      #update tblName set uColName = newVal where wColName = oldVal
      #uColName > pos | newVal > av2 | wColName > ind | oldVal > av
      awk -F';' -v pos="$position" -v av2="${arr[5]}" -v ind="$index" -v av="${arr[9]}" 'BEGIN {
          IGNORECASE=1;
        }
        {
            line=$0
            #print "00"
            #print line
            if($ind==av)
            {
              #print"01"
              #print $ind
              #print av
              line=""
              for(i=1;i<=NF;i++)
              {
                #print "000"
                #print i
                #print pos
                #print line
                if(i==pos)
                {
                  line=line av2";"
                  #print "11"
                  #print line
                }
                else
                {
                  line=line$i";"
                  #print "22"
                  #print line
                }
                #print "02"
                #print line
              }

              if(pos==NF)
              {
                line=line av2
                #print "33"
                #print line
              }
              else
              {
                line=line$NF
                #print "44"
                #print line
              }
            }
            #print "55"
            print line
        }' "$tn" > temp
      cat temp > "$tn"
  fi
}
################################################################################
function deleterecord(){ ##delete from tblName where {CONDITION}
  echo "${arr[@]}"
  if [ "${arr[0]}"='delete' -a "${arr[1]}"="from" -a "${arr[3]}"="where" ]
  then
  tn="./$useddatabase/${arr[2]}.t"
  tableName="./$useddatabase/${arr[2]}.m"

  var=`head -n 1 $tn`
  echo $var;
  IFS=";" read -a fields <<< "$var";
  index=1;
  for f in "${fields[@]}"
        do
          if [ $f == "${arr[4]}" ]; then
            echo $f
            echo $index;
            echo ${arr[4]};
            break;
          else
            echo $f
            index=`expr $index + 1`
            echo $index;
            echo ${arr[4]};
          fi
      done
  echo $index
  if [ -f temp ]
  then
  rm temp
  fi
  awk -F';' -v ind="$index" -v av="${arr[6]}" 'BEGIN {
        IGNORECASE=1;
      }
      {

        if($ind!=av)
        {

          print($0);

        }

      }
      END {

    }' "$tn" >> temp
    cat temp > "$tn"
  #awk -F ';' '{ if ( "'$loc'" != "'${arr[6]}'" )  "'$loc'" >> temp;  cat temp > "'$tn'"}'
  fi
}
################################################################################
function selectrecord(){ ##select all from tblName select with where condition
  echo "${arr[@]}"
  if [ "${arr[1]}" == "all" -a "${arr[4]}" == "where" ]; then
    tablename="./$useddatabase/${arr[3]}.t"
    if [[ -f $tablename  ]]; then
      echo "selcting all with where condition";
      query=$(head -n 1 $tablename);
      IFS=';'  read -a fields <<< "$query";
      #IFS=',() ' read -a arr <<< "$query";
      echo ${fields[@]};

      #get index number of selection column
      index=1;
      for f in "${fields[@]}"
        do
          if [ $f == "${arr[5]}" ]; then
            echo $f
            echo $index;
            echo ${arr[5]};
            break;
          else
            echo $f
            index=`expr $index + 1`
            echo $index;
            echo ${arr[5]};
          fi
      done

      #awk -F";" '{ print $1 $2 $3 }' $tablename
      awk -F';' -v ind="$index" -v av="${arr[7]}" 'BEGIN {
        IGNORECASE=1;
      }
      {
        if($ind == av)
        {
          for(i=1;i<=NF;i++)
          printf ("%15s",$i);
          printf("\n");
        }
      }
      END {
        printf ("\n");
      }' "$tablename"

    else
      echo "Table ${arr[3]} Doesn't Exist"
    fi
  elif [ "${arr[1]}" == "all" ]; then
    tablename="./$useddatabase/${arr[3]}.t"
    if [[ -f $tablename  ]]; then
      echo "select all data"
      #read header <"$tablename"
      awk -F ";" 'BEGIN {
        IGNORECASE=1;
      }
      {
        for(i=1;i<=NF;i++)
        printf ("%15s",$i);
        printf("\n");
      }
      END {
        printf ("\n");
      }' "$tablename"
      #while read record; do
      #  echo "$record";
      #done < "$tablename"
    fi

  else
    ##Select specific
    echo "Select specific with where condition";
  fi
}
################################################################################
function altertable(){ ##alter table tblName add column colName | alter table tblName drop column colName
  echo "${arr[@]}"
  if [ "${arr[0]}" = "alter" -a "${arr[1]}" = "table" ]
  then
    if (( $usesdatabase !=0 ));
    then
      tn="./$useddatabase/${arr[2]}.t"
      tableName="./$useddatabase/${arr[2]}.m"
      if [ -f $tableName ]; then
        if [ "${arr[3]}" = "add" ]; then
          echo "Altering Table, Adding Column";
          flag=`awk -F'::' -v val="${arr[5]}" 'BEGIN {
                IGNORECASE=1;
              }
              {

                if($1==val)
                {
                  print "1";
                }
              }
              END {

            }' "$tableName"`
          echo $flag;
          if [ "$flag" != "1" ]; then
            fields=""
            echo "You will be asked about field's properties...";
            echo -e "Field's Name is:" ${arr[5]} ;
            #read -r fld;
            fld="${arr[5]}";
            echo -e "Primary Key (y/n)?";
            read -r pk;
            echo -e "Foreign Key (y/n)?";
            read -r fk;
            if [ $pk = "y" ]; then
              uq="y";
              nn="y";
              df="n";
            else
              echo -e "Unique (y/n)?";
              read -r uq;
              if [ $uq = "y" ]; then
                nn="y";
                df="n";
              else
                echo -e "Not NULL (y/n)?";
                read -r nn;
                echo -e "Has Default Value (y/n)?";
                read -r df;
                if [ $df = "y" ]; then
                  echo -e "Enter Default value:";
                  read -r df;
                else
                  df="n";
                fi
              fi
            fi
            echo -e "Enter Data Type (int/char/mixed):";
            read -r dt;
            if [ $dt = "int" ]; then
              dt="int";
              echo -e "Has Check Condition (y/n)?";
              read -r ch;
              if [ $ch = "y" ]; then
                echo -e "Less than or greater than or equal [lt , gt , le, ge]:";
                read -r cons;
                echo -e "Enter Condition Value:"
                read -r cv;
                ch="$cons:$cv";
              fi
            elif [ $dt = "char" ]; then
              dt="char";
            else
              dt="mixed";
            fi
            rec=" ";
            rec="$fld::$pk::$fk::$nn::$uq::$df::$ch::$dt";

            echo "$rec" >> $tableName;

            if [ "$df" == "n" ]; then
              df="";
            fi
            if [ -f temp ]
            then
            rm temp
            fi
            awk -F';' -v col="$fld" -v def="$df" 'BEGIN {
                  IGNORECASE=1;
                }
                {

                  if(NR==1)
                  {
                    print $0 ";" col;
                  }
                  else
                  {
                    print $0 ";" def;
                  }
                }
                END {

              }' "$tn" >> temp
              cat temp > "$tn"
            echo -e "Column Created and Added Successfully"
            echo "Table ${arr[2]} Altered Successfully."
          else
            echo "Field Already Exists!"
          fi
        elif [ "${arr[3]}" = "drop" ]; then
          echo "Altering Table, Dropping Column";
        else
          echo "Alter Syntax Error!"
        fi
      else
        echo "Table ${arr[2]} Not Exist!"
      fi
    else
      echo "Choose 'Use' Database First!";
    fi
  else
    echo "Syntax Error in: " "${arr[@]}"
  fi
}
################################################################################
function truncatetable(){ ##truncate table tblName
  echo "${arr[@]}"
  if [ "${arr[0]}" = "truncate" -a "${arr[1]}" = "table" ]
  then
    if (( $usesdatabase !=0 ));
    then
      tn="./$useddatabase/${arr[2]}.t"
      tableName="./$useddatabase/${arr[2]}.m"
      if [ -f $tableName ]; then
        trunva=`head -n 1 $tn`
        rm -f "$tn";
        touch "$tn"
        echo "$trunva" >> "$tn"
        echo "Table ${arr[2]} Truncated Successfully."
      else
        echo "Table ${arr[2]} Not Exist!"
      fi
    else
      echo "Choose 'Use' Database First!";
    fi
  fi
}
################################################################################
function droptable(){ ##drop table tblName | drop database dbName
  echo "${arr[@]}"
  if [ "${arr[0]}" = "drop" -a "${arr[1]}" = "table" ]; then
    if (( $usesdatabase !=0 )); then
      tn="./$useddatabase/${arr[2]}.t"
      tableName="./$useddatabase/${arr[2]}.m"
      if [ -f $tableName ]; then
        rm -f "$tn";
        rm -f "$tableName";
        echo "Table ${arr[2]} Deleted Successfully."
      else
        echo "Table ${arr[2]} Not Exist!"
      fi
    else
      echo "Choose 'Use' Database First!";
    fi
  elif [ "${arr[0]}" = "drop" -a "${arr[1]}" = "database" ]; then
    if [ -d "${arr[2]}" ]; then
      rm -dR "${arr[2]}";
      echo "Database ${arr[2]} Deleted Successfully."
    else
      echo "Database ${arr[2]} Not Exist!";
    fi
  else
    echo "Can't Delete Database or Table, Syntax error!";
  fi
}
################################################################################
function needhelp(){
  echo "${arr[@]}"
  while read line
  do
    echo "$line"
  done < "help.h"

  echo "Press b to back menu or e to exit";
  while true; do
    read op;
    if [ "$op" = "b" ]; then
      choice
    elif [ "$op" = "e" ]; then
      exit 0;
    else
      echo "Wrong Choice!"
    fi
  done;
}
################################################################################
#coice: First called function appears to user
function choice(){
  echo $PS1;
  #read -a arr;
  read query;
  IFS=',() ' read -a arr <<< "$query";
  echo "${arr[@]}"

  case "${arr[0]}" in
    show)
      echo Show Databaes or Tables
      showexists $arr
    ;;

    use)
      echo Use Database
      useexists $arr
    ;;

    create)
      echo Create Database or Table
      createnew $arr
    ;;

    alter)
      echo Alter Table
      altertable $arr
    ;;

    truncate)
      echo Truncate table - delete all records
      if (( $usesdatabase !=0 )); then
        truncatetable $arr
      else
        echo "Choose 'Use' Database First!";
      fi
    ;;

    drop)
      echo Drop table or Database - delete all records
      droptable $arr
    ;;

    insert)
      echo Insert into table
      if (( $usesdatabase !=0 )); then
        insertrecord $arr
      else
        echo "Choose 'Use' Database First!";
      fi
    ;;

    update)
      echo Update Table
      if (( $usesdatabase !=0 )); then
        updaterecord $arr
      else
        echo "Choose 'Use' Database First!";
      fi
    ;;

    delete)
      echo Delete from Table
      if (( $usesdatabase !=0 )); then
        deleterecord $arr
      else
        echo "Choose 'Use' Database First!";
      fi
    ;;

    select)
      echo Select from Table
      if (( $usesdatabase !=0 )); then
        selectrecord $arr
      else
        echo "Choose 'Use' Database First!";
      fi
    ;;

    f)
    echo Help
      needhelp
    ;;

    e)
      echo Good Bye `whoami` !
      sleep 1
      exit
    ;;

    *)
      echo Wrong Input!!!
    ;;
  esac
}
#End of choice function
################################################################################
#First called Lines of code
#un-comment following line to enable debugging mode
set -x
#Show splash screen
clear
toilet -f term -F border --gay "DBMS"
figlet "           By"
figlet -f mono12 "   R&E"
figlet -f digital 'Write F1 for help & manual - Esc to exit'
sleep 1
clear

##Welcoming user
echo "Welcome `whoami` to R&E Simple DBMS :)"
PS1="Query \"f\"-help|\"e\"-exit>>"
echo $PS1
#starting to recieve queries

while true; do
  choice
done

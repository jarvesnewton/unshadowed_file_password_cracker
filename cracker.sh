#! /bin/bash

awk_FILE_BINARY=`which awk`
OPENSSL_FILE_BINARY=`which openssl`
wc_FILE_BINARY=`which wc`
echo_FILE_BINARY=`which echo`
cut_FILE_BINARY=`which cut`
cat_FILE_BINARY=`which cat`
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'

# To check if the unshadowed file and the wordlist file exists
check_if_file_exists () {
filename=$1
  if [ ! -f $filename ]; then
    echo "0"
  else
    echo "1"
  fi
}


if [[ $# != 2 ]] # Wrong number of arguments
then
  echo -e "${RED}###################### ERROR ###################### \n"
  echo -e "${YELLOW}Please give valid number of arguments: \n\n${NC}"
  echo -e "${GREEN}**** USAGE **** \n"
  echo -e "${BLUE}./cracker <dictionary_file> <linux_password_file>${NC}"
else
  # check if files exist
  dictionary_file=$1
  linux_password_file=$2
  check_dictionary_file=`check_if_file_exists $dictionary_file`
  check_linux_password_file=`check_if_file_exists $linux_password_file`
  file_check_result=$(($check_dictionary_file + $check_linux_password_file))
  # If both files exist then go ahead
  if [ $file_check_result == 2 ]
  then
    # Lets start cracking
    # Get the number of lines in passwd file
    length_of_passwd_file=`wc -l $linux_password_file | $awk_FILE_BINARY '{print $1}'`
    n=1
    # reading each line: that means we will run password cracking for each user
    while read line; do
    # fetching the salt used which is the portion of each line in file between 2nd and 3rd $ sign
    salt=$($awk_FILE_BINARY -F: '$2 ~ /^\$/ {print $2}' $linux_password_file | $cut_FILE_BINARY -c-11 | $cut_FILE_BINARY -d'$' -f3 | $awk_FILE_BINARY "NR == $n")
    # fetching the algo used for hashing, every entry in the unshadowed file will have 2 charachter entry after "user:" which eqautes as follows :
    # if $6 -> sha512
    # if $2 -> blowfish
    # if $2a -> eksblowfish
    # if $5 -> sha 256
    # if $1 -> md5
    algo=$($awk_FILE_BINARY -F: '$2 ~ /^\$/ {print $2}' $linux_password_file | $cut_FILE_BINARY -c-10 | $cut_FILE_BINARY -d'$' -f2 | $awk_FILE_BINARY "NR == $n")
    # Next we will fetch the whole thing from the unshadowed file which contains : algo + salt + password_hash
    whole_thing=$($awk_FILE_BINARY -F: '$2 ~ /^\$/ {print $2}' $linux_password_file | $awk_FILE_BINARY "NR == $n")
    # Next we will fetch the first entry in the file on each line which is the user name.
    user=$(cat $linux_password_file | $cut_FILE_BINARY -d':' -f1 | $awk_FILE_BINARY "NR == $n")
      # We will now fetch each line from the wordlist
      while read trial_password; do
        # For each entry we will create a hash of the word with the algortihm and salt we obtained before, the '&' runs every user password cracking as new process in linux operating system and returns 0 to the master program, achieveing multiprocessing.
        cracked_hash=$($OPENSSL_FILE_BINARY passwd -$algo -salt $salt $trial_password &)
        # we will use this whole hash+salt to compare with the whole actual hash+salt and see if it matches, if it does then got the password cracked for that user.
        if [ $cracked_hash == $whole_thing ]
        then
          echo "Found passwd for user $user: $trial_password"
        fi
      done < $dictionary_file
    n=$((n+1))
    #echo $whole_thing
    done < $linux_password_file
  else
    echo "${YELLOW} File(s) do not exist \n\n${NC}"
  fi
fi

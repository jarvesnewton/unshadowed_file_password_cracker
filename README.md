----------------------
Command Line Arguments
----------------------

Example:  ./cracker <dictionary_file> <linux_password_file>

<dictionary_file> The file which contains a list of words to use trial and error to crack the password

<linux_password_file> The unshadoId password_dump you receive after unshadowing

  to retrieve this file run :

      unshadow /etc/passwd /etc/shadow > ~/file_to_crack

------------------
Setup requirements
------------------

We are using some linux programs like :

openssl
awk
cut
cat
echo
wc

These are default programs that come with linux distributions by default and are the only tools needed to run the cracker, if these programs are not available with your flavour of linux, Please use the following commands that suits your linux flavour :

MAC           : brew install openssl awk cut cat echo wc
Debian/Ubuntu : apt-get install -y openssl awk cut cat echo wc
REHL/CentOS   : yum install openssl awk cut cat echo wc


----------------
Design Decisions
----------------

A typical entry in this file looks like this :

victor:$6$AMtP9.dK$RJlr64buwvj93ksE/XzO3lNBY459rr9N5eKgx5acZ3O89idQmeiIM7UrmdEngAsvaOMJdqpt/.kcbhIPvDDIy/:1004:1004:,,,:/home/victor:/bin/bash

Where :

Victor 		  -> username
$6      	  -> type of hashing algorithm used
AMtP9.dK	  -> Salt
RJlr64buwvj93ksE/XzO3lNBY459rr9N5eKgx5acZ3O89idQmeiIM7UrmdEngAsvaOMJdqpt/.kcbhIPvDDIy/ 	-> Hashed password

I decided to fetch these entries for each user separately and save them as variables. For each user I will create a password hash with the received salt and each word in the wordlist provided to us as command line argument to the program and using the hashing algorithm detected by analyzing the unshadoId file.

We can generate the resultant password hash by using the following command :
openssl passwd -6 -salt AMtP9.dK word_from_wordlist

We now compare the generated hashed password with “$6$AMtP9.dK$RJlr64buwvj93ksE/XzO3lNBY459rr9N5eKgx5acZ3O89idQmeiIM7UrmdEngAsvaOMJdqpt/.kcbhIPvDDIy/” if it is a match then we have cracked the password for that user.

We have implemented multi processing in the script so that password of every user is cracked as a different task/process using ‘&’ at the end of openssl passwd command.

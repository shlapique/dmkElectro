#!/bin/bash

url=$1
dir="$(pwd)/out"
dir_h="${dir}/src"
counter=1
cur_dir="${dir_h}$counter"
global_key=""

if [ ! -e $dir ]
then		
	mkdir $dir 
	mkdir "${dir_h}$counter"
	wget -P "${dir_h}$counter" -O "${dir_h}$counter/source" $url
else
	file_num="$(ls $dir -1bA | wc -l)"
	cur_dir="${dir_h}$((file_num+1))"
	mkdir $cur_dir 
	wget -P $cur_dir -O "$cur_dir/source" $url
fi

###########
total_size="$(grep '<span id="bmkpagetotalnum">' "$cur_dir/source")"
total_size=${total_size/\<\/span\>\<\/div\>}
total_size=${total_size/\<div class\=\"CurPage\"\>\С\т\р\. \<span id\=\"bmkpagenum\" class\=\"CurPageScroller\"\>\1\<\/span\> \/\<span id\=\"bmkpagetotalnum\"\>}
extra_sub=${total_size:0: 12}
total_size=${total_size/$extra_sub}
total_size=${total_size:: -1} #4

###########
global_key="$(grep '000001' "$cur_dir/source")"
extra_val=${global_key:0: 440}
global_key=${global_key/$extra_val}
##########3

#----
key="$(expr index "$url" ?)"
rul=${url:0: $((key-1))}
rul=${rul/http\:\/\/elibrary\.mai\.ru\/MegaPro\/Download\/ToView\/}
rul=${#rul}
#-----

########
extra_val=${global_key:0: $((117+$rul))}
global_key=${global_key/$extra_val}
global_key=${global_key/\000\001\.png\" style\=\"float\:left\;text\-align\:center\;\" \/\>} #4
global_key=${global_key::-1}
###########

extra="00000"
for ((i=1; i<$total_size; i++))
do
	str="$extra$i"
	if [[ ${#str} -ne 6 ]] #if not euq
	then
		extra=${extra:1}
		str="$extra$i"		
	fi
	out="http://elibrary.mai.ru/ProtectedView/Content/tmp/${global_key}${str}.png"
	wget -q -P "$cur_dir" --wait=1000000 $out
done

#find "$PWD" -iname '*.png' -execdir convert '{}' '{}'.pdf \;

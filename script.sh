#!/bin/bash

usage(){
    echo "usage: ${0##*/} script [-H | --help]"
    echo -e "\t-u, --url        url of the book source"
    echo -e "\t-d, --directory  dir to save images"
    echo -e "\t-p, --pdf        to convert images into one pdf (by default 'out.pdf')"
    echo -e "\t-h, --help       print to the output this message"
}

error(){
    echo -e "error occured: $1"
    usage
}

rewrite_out(){
    echo -e "Directory 'out' already exists !"
    echo -e "You haven't specified directory for NEW source !"
    echo -e "delete 'out' or move to another place"
    exit 2
}

### some variables
url=""
url_flag=0
dir="$(pwd)/out"
pdf_conv_flag=0
pdf_name="out.pdf"
###

#flags input
while [ ! -z "$1" ];
do
    case "$1" in
        --url | -u )        
            shift
            url=$1
            url_flag=1
            ;;
        --directory | -d )   
            shift
            dir="$(pwd)/$1"
            ;;
        --pdf | -p )
            shift
            pdf_conv_flag=1
            if [ ! -z "$1" ]
            then
                pdf_name=$1
            fi
            ;;
        --help | -h )       
            usage
            exit 0
            ;;
        * )                 
            error "unknown argument"
            exit 1
            ;;
    esac
shift
done

#check for newbies
if [ $url_flag == 0 ];
then
    usage
    exit 4
fi

#check for dummies
if [ ! -e $dir ];
then		
    mkdir $dir 
	wget -P "${dir}" -O "${dir}/source" $url
else
    rewrite_out
fi

###########
total_size="$(grep '<span id="bmkpagetotalnum">' "$dir/source")"
total_size=${total_size/\<\/span\>\<\/div\>}
total_size=${total_size/\<div class\=\"CurPage\"\>\С\т\р\. \<span id\=\"bmkpagenum\" class\=\"CurPageScroller\"\>\1\<\/span\> \/\<span id\=\"bmkpagetotalnum\"\>}
extra_sub=${total_size:0: 12}
total_size=${total_size/$extra_sub}
total_size=${total_size:: -1} #4
###########

###########
global_key="$(grep '000001' "$dir/source")"
extra_val=${global_key:0: 440}
global_key=${global_key/$extra_val}
###########

#----
key="$(expr index "$url" ?)"
rul=${url:0: $((key-1))}
rul=${rul/http\:\/\/elibrary\.mai\.ru\/MegaPro\/Download\/ToView\/}
rul=${#rul}
#-----

########
global_key=${global_key/${global_key:0: $((117+$rul))}}
global_key=${global_key/\000\001\.png\" style\=\"float\:left\;text\-align\:center\;\" \/\>} #4
global_key=${global_key::-1}
###########

#%%%%%%%
extra="00000"
for ((i=1; i<$total_size; i++))
do
	str="$extra$i"
	if [ ${#str} -ne 6 ]; #if not euq
	then
		extra=${extra:1}
		str="$extra$i"		
	fi
	out="http://elibrary.mai.ru/ProtectedView/Content/tmp/${global_key}${str}.png"
	wget -q -P "$dir" $out
done
#%%%%%%%

#pdf convertion (optional)
#requires 'ghostscript' and 'ImageMagick' dependensies
if [ $pdf_conv_flag == 1 ];
then
    convert "$dir/*.png" $pdf_name
fi

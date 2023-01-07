# naive script to download "protected" files from online uni library 

on source site there're a couple of problems:
*(because of a crooked web site programmer)*
* some books are displayed incorrectly 
* the book should be published no later than 2019-2020, due to change in page structure (for "parsing")

## required dependencies
### openSUSE Tumbleweed
```bash
zypper in ghostscript imagemagick 
```
*on most distros may already be installed by default*

***and if you want to OCR:***
```bash
zypper ar https://download.opensuse.org/repositories/home:frank_kunz/openSUSE_Tumbleweed/home:frank_kunz.repo
zypper ref
zypper in OCRmyPDF
```

## usage
to start just type `./script --help`

#!/bin/sh

return_dir=`pwd`

echo && echo "Downloading updated pathogen." && echo

cd ~/.vim/autoload/
wget -qN https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

if grep -qEe '(filetype plugin off|call pathogen#infect\(\)|filetype indent on)' ~/.vimrc
then
	echo "Pathogen already in .vimrc. Passing..." && echo
else

	sed -i '1i filetype plugin off\ncall pathogen#infect()\nfiletype indent on' ~/.vimrc
	
	echo "Prepended pathogen init to .vimrc." && echo
fi

mkdir -p ~/.vim/bundle
cd ~/.vim/bundle

if [ -d "vim-markdown" -a -w "vim-markdown" ]
then

	echo "vim-markdown already exists. Updating..." && echo
	cd vim-markdown
	git pull
else

	echo "Cloning vim-markdown"
	git clone --depth=1 git://github.com/tpope/vim-markdown.git

fi

cd $return_dir

ret=$?
if [ $ret -ne 0 ]; then
	echo && echo "vim-markdown failed to update." >&2
else
	 echo && echo "vim-markdown was updated."
fi

exit $ret

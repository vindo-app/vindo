let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Developer/github/vindo-app/vindo-app.github.io
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +1 js/compatibility.js
badd +1 _includes/head.html
badd +1 compatibility.html
badd +1 _layouts/compat.html
badd +1 _sass/_about.scss
badd +1 _data/ratings.yml
badd +1 _data/rating_colors.yml
badd +1 _sass/compatibility.scss
badd +13 _includes/highlight.html
badd +7 _sass/_header.scss
badd +20 css/main.scss
badd +5 _layouts/default.html
badd +1 _includes/header.html
badd +1 _sass/_blog.scss
badd +1 ~/.vimrc
badd +1 _includes/navbar.html
badd +1 _includes/postcontent.html
badd +1 index.html
badd +1 _includes/headline.html
badd +4 _includes/_index.scss
badd +10 _sass/_navbar.scss
badd +1 _sass/_compat.scss
badd +1 _sass/_base.scss
badd +1 _sass/_index.scss
badd +1 js/scroll.js
badd +1 _compatibility/portal.md
badd +0 _data/features.yml
badd +0 _data/programs.yml
badd +1 _layouts/homepage.html
badd +0 _sass/_heading.scss
badd +0 _data/pages.yml
argglobal
silent! argdel *
argadd js/compatibility.js
edit _sass/_index.scss
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 242 - ((73 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
242
normal! 0
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/index.html
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 10 - ((9 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
10
normal! 0
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/_data/features.yml
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/_data/pages.yml
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 2 - ((1 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 0
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/_sass/_navbar.scss
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 15 - ((14 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
15
normal! 09|
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/_includes/navbar.html
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 020|
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/_layouts/homepage.html
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 4 - ((3 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4
normal! 065|
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/js/scroll.js
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 12 - ((11 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
12
normal! 047|
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabedit ~/Developer/github/vindo-app/vindo-app.github.io/_sass/_base.scss
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 37) / 74)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 07|
lcd ~/Developer/github/vindo-app/vindo-app.github.io
tabnext 2
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :

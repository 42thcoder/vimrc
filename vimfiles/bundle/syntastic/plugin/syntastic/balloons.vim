if exists("g:loaded_syntastic_notifier_balloons")
    finish
endif
let g:loaded_syntastic_notifier_balloons = 1

if !exists("g:syntastic_enable_balloons")
    let g:syntastic_enable_balloons = 1
endif

if !has('balloon_eval')
    let g:syntastic_enable_balloons = 0
endif

let g:SyntasticBalloonsNotifier = {}

" Public methods {{{1

function! g:SyntasticBalloonsNotifier.New()
    let newObj = copy(self)
    return newObj
endfunction

function! g:SyntasticBalloonsNotifier.enabled()
    return has('balloon_eval') && syntastic#util#var('enable_balloons')
endfunction

" Update the error balloons
function! g:SyntasticBalloonsNotifier.refresh(loclist)
    let b:syntastic_balloons = {}
    if self.enabled() && !a:loclist.isEmpty()
        call syntastic#log#debug(g:SyntasticDebugNotifications, 'balloons: refresh')
        let buf = bufnr('')
        let issues = filter(a:loclist.copyRaw(), 'v:val["bufnr"] == buf')
        if !empty(issues)
            for i in issues
                if has_key(b:syntastic_balloons, i['lnum'])
                    let b:syntastic_balloons[i['lnum']] .= "\n" . i['text']
                else
                    let b:syntastic_balloons[i['lnum']] = i['text']
                endif
            endfor
            set beval bexpr=SyntasticBalloonsExprNotifier()
        endif
    endif
endfunction

" Reset the error balloons
" @vimlint(EVL103, 1, a:loclist)
function! g:SyntasticBalloonsNotifier.reset(loclist)
    if has('balloon_eval')
        call syntastic#log#debug(g:SyntasticDebugNotifications, 'balloons: reset')
        set nobeval
    endif
endfunction
" @vimlint(EVL103, 0, a:loclist)

" Private functions {{{1

function! SyntasticBalloonsExprNotifier()
    if !exists('b:syntastic_balloons')
        return ''
    endif
    return get(b:syntastic_balloons, v:beval_lnum, '')
endfunction

" vim: set sw=4 sts=4 et fdm=marker:

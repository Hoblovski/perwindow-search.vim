# perwindow-search.vim
Allows different vim windows to have their own search patterns.

Demonstration:
[![demo](https://asciinema.org/a/565707.svg)](https://asciinema.org/a/565707?autoplay=1)

# Usage
Just same as vim searches.
* `/` : start a search
* `n` and `N` : navigate among results
* `*` and `#` : search for word under the cursor
* the register `@/` contains the search pattern of the current window.

Different from plain vim:
* `/ <C-C>` : cancel search highlight i.e. `:nohls`

# Installation
Like any other vim plugins.

For example if you use vim-plug, add the following line to your .vimrc:
```
Plug 'hoblovski/perwindow-search.vim'
```

# Requirements & Troubleshooting
Working fine with my vim 8.1.

The plugin is really simple and it should work with any recent vim with a
reasonable feature set.  Compatibility with other plugins should be fine though
not tested.
Try the following steps in case of trouble:
* Delete `set hls` or `set hlsearch` in your .vimrc
* Ensure `/ N n * #` are not mapped, because perwindow-search remaps them.
* File an issue, including your `vim --version` and your plugin list.



# Forked Explanation

This fork is mainly for my personal use, with a few bug fixes applied.

## Fixed List

1. **BufModifiedSet**

   The `BufModifiedSet` autocommand was removed from Neovim(0.11) in commit `25fcd59`.

   See the related comment in this PR: <https://github.com/neovim/neovim/pull/35610>

## Deprecated List

2. **nvim[_buf|_win]_[gs]et_option**

   The `nvim[_buf|_win]_[gs]et_option` functions were deprecated in Neovim
   in commit `549586b`.

   See the related comment in this PR: <https://github.com/neovim/neovim/pull/21474>

## Improved List

1. use nvim floating window instead of plenary popup window

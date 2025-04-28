## dotfiles


## symlinks
move the file/folder to symlink from the original dir to the target dir.
then create a symlink from the .dotfiles folder to the original dir

note: make sure you use type the full address from your `$HOME` or `~`

```sh
ln -sf [target_address] [symlink_address]
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
```

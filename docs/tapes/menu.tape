Output docs/gifs/menu.gif

Set Shell "bash"
Set Theme "Dracula"
Set FontSize 13
Set Width 900
Set Height 500
Set Framerate 30
Set TypingSpeed 50ms

Hide
Type "export PS1='$ '"
Enter
Type "bash /Users/sp/code/tmux-agents/docs/demo/setup.sh"
Enter
Sleep 2s
Type "tmux attach-session -t agents-demo"
Enter
Sleep 1s

# Create dashboard first (hidden)
Ctrl+B
Sleep 400ms
Type "g"
Sleep 400ms
Type "d"
Sleep 4s
Show

# prefix g D → dashboard menu
Ctrl+B
Sleep 400ms
Type "g"
Sleep 400ms
Type "D"
Sleep 3s

Escape
Sleep 500ms

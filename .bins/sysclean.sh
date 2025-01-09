function sysclean {
    if [[ $1 == "update" ]]; then
        sudo pacman -Syyu  # do 'sysup update' if you want to update+clean 
    fi
    sudo pacman -Scc
    sudo pacman -Rns $(pacman -Qdtq)
    echo "Clean-up done!"
}


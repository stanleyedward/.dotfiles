function sysclean {
    if [[ $1 == "update" ]]; then
        sudo pacman -Syyu  # do 'sysup update' if you want to update+clean 
    fi
    sudo pacman -Scc
    sudo pacman -Rns $(pacman -Qdtq)
    yay -Sc
    echo "Clean-up for system packages completed."

    pip cache purge
    conda clean --all -y
    npm cache clean --force
    echo "Clean-up for Python packages completed."

    read -p "do you want to delete ~/.cache(y/n)?" answer

    if [[ $answer == "y" || $answer == "Y" || $answer == "yes" || $answer == "Yes" ]]; then
	rm -rf ~/.cache/*
	echo "Cache directory cleaned."
    else
	echo "Cache directory not cleaned."
    fi
    
    rm -rf ~/.local/share/Trash/files/*
    rm -rf ~/.local/share/Trash/info/*
}


#!/data/data/com.termux/files/usr/bin/bash 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

header() {
    clear
    echo -e "${GREEN}"
    echo "=========================================="
    echo "   Termux Customization Tool"
    echo "   Ubuntu/Kali Linux Theme Installer"
    echo "=========================================="
    echo -e "${NC}"
}

check_pkg() {
    if [ ! -x "$(command -v $1)" ]; then
        echo -e "${RED}[ERROR]${NC} $1 not installed. Installing..."
        pkg install -y $1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[SUCCESS]${NC} $1 installed successfully."
        else
            echo -e "${RED}[ERROR]${NC} Failed to install $1."
            exit 1
        fi
    fi
}

install_requirements() {
    echo -e "${YELLOW}[INFO]${NC} Updating packages..."
    pkg update -y && pkg upgrade -y
    
    echo -e "${YELLOW}[INFO]${NC} Installing requirements..."
    pkg install -y curl wget git python fish zsh micro neofetch cmatrix figlet toilet openssh man
    
    pkg install -y ncurses-utils
    
    echo -e "${GREEN}[SUCCESS]${NC} All requirements installed."
}

install_zsh() {
    echo -e "${YELLOW}[INFO]${NC} Installing Zsh and Oh-My-Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo -e "${YELLOW}[INFO]${NC} Oh-My-Zsh already installed."
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
    
    echo -e "${GREEN}[SUCCESS]${NC} Zsh and plugins installed."
}

configure_zsh() {
    echo -e "${YELLOW}[INFO]${NC} Configuring Zsh..."
    
    if [ -f "$HOME/.zshrc" ]; then
        mv $HOME/.zshrc $HOME/.zshrc.backup
    fi
    
    curl -fsSL https://raw.githubusercontent.com/adi1090x/termux-style/master/files/zshrc -o $HOME/.zshrc
    
    chsh -s zsh
    
    echo -e "${GREEN}[SUCCESS]${NC} Zsh configured."
}

install_themes() {
    echo -e "${YELLOW}[INFO]${NC} Installing custom theme..."
    
    if [ ! -d "$HOME/termux-style" ]; then
        git clone https://github.com/adi1090x/termux-style.git $HOME/termux-style
        cd $HOME/termux-style
        chmod +x install
        ./install
        cd $HOME
    else
        echo -e "${YELLOW}[INFO]${NC} Termux-style already installed."
    fi
    
    echo -e "${GREEN}[SUCCESS]${NC} Theme installed."
}

install_kali_tools() {
    echo -e "${YELLOW}[INFO]${NC} Installing Kali Linux tools..."
    
    pkg install -y proot proot-distro
    
    if [ ! -x "$(command -v proot-distro)" ]; then
        echo -e "${RED}[ERROR]${NC} proot-distro not installed."
    else
        if [ ! -d "$HOME/.termux/proot-distro/installed-rootfs/ubuntu" ]; then
            proot-distro install ubuntu
            echo -e "${GREEN}[SUCCESS]${NC} Ubuntu installed via proot."
        else
            echo -e "${YELLOW}[INFO]${NC} Ubuntu already installed."
        fi
    fi
    
    pkg install -y nmap hydra python python2 python3 php ruby perl \
        clang make libtool autoconf pkg-config nodejs-lts \
        libxml2 libxslt libffi libjpeg-turbo libpng
        
    python -m ensurepip --upgrade
    pip install --upgrade pip
    
    pip install requests bs4 selenium mechanize numpy scapy
    
    echo -e "${GREEN}[SUCCESS]${NC} Kali Linux tools installed."
}

setup_fonts_colors() {
    echo -e "${YELLOW}[INFO]${NC} Setting up fonts and colors..."
    
    if [ ! -f "$HOME/.termux/font.ttf" ]; then
        mkdir -p $HOME/.termux
        curl -fsSL https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Regular/complete/Fura%20Mono%20Regular%20Nerd%20Font%20Complete.otf -o $HOME/.termux/font.ttf
    fi
    
    if [ ! -f "$HOME/.termux/colors.properties" ]; then
        curl -fsSL https://raw.githubusercontent.com/adi1090x/termux-style/master/colors/brogrammer -o $HOME/.termux/colors.properties
    fi
    
    echo -e "${GREEN}[SUCCESS]${NC} Fonts and colors configured."
}

create_aliases() {
    echo -e "${YELLOW}[INFO]${NC} Creating aliases..."
    
    cat >> $HOME/.zshrc << EOL

alias kali='proot-distro login ubuntu'
alias ls='ls -la --color=auto'
alias ll='ls -l'
alias update='pkg update && pkg upgrade'
alias neo='neofetch'
alias matrix='cmatrix'
alias ssh-start='sshd'
alias ssh-stop='pkill sshd'
EOL

    echo -e "${GREEN}[SUCCESS]${NC} Aliases created."
}

finish() {
    echo -e "${GREEN}"
    echo "=========================================="
    echo "Installation Complete!"
    echo "Restart Termux to see changes"
    echo "=========================================="
    echo -e "${NC}"
    echo "Features installed:"
    echo "- Zsh with Oh-My-Zsh"
    echo "- Powerlevel10k theme"
    echo "- zsh-syntax-highlighting plugin"
    echo "- zsh-autosuggestions plugin"
    echo "- Custom fonts and colors"
    echo "- Kali Linux tools"
    echo "- Ubuntu environment via proot"
    echo "- Custom aliases"
    echo ""
    echo "Run 'termux-style' to change themes"
    echo "Run 'kali' to enter Ubuntu environment"
}

main() {
    header
    install_requirements
    install_zsh
    configure_zsh
    install_themes
    install_kali_tools
    setup_fonts_colors
    create_aliases
    finish
}

main

#!/bin/sh

echo "Setting up your Mac"

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Update Homebrew recipes
  brew update
  brew install git
fi

# Check for Oh My Zsh and install if we don't have it
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Check for SDKMAN and install if we don't have it
if [ ! -d "$HOME/.sdkman" ]; then
  /bin/sh -c "$(curl -fsSL https://get.sdkman.io)"

  # Install OpenJDK 16
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk i java 16.0.1.hs-adpt
fi

# Clone dotfile repo
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/amscotti/dotfiles.git $HOME/.dotfiles
fi

# Install all our dependencies with bundle
brew bundle --file $HOME/.dotfiles/Brewfile

dotfiles=( ".gitconfig" ".zshrc" )

for f in "${dotfiles[@]}"
do
    echo "Creating symlinks for $f"
    rm -rf $HOME/$f
    ln -s $HOME/.dotfiles/$f $HOME/$f
done

# Check to see if a SSH has been created
if [ ! -f $HOME/.ssh/id_ed25519 ]; then
    echo "Generating a new SSH key"

    # Generating a new SSH key
    ssh-keygen -t ed25519 -C "$USER@$HOST" -f $HOME/.ssh/id_ed25519

    # Adding your SSH key to the ssh-agent
    eval "$(ssh-agent -s)"

    touch $HOME/.ssh/config
    echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

    ssh-add -K $HOME/.ssh/id_ed25519

    # Adding your SSH key to your GitHub account
    # https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
    echo "run 'pbcopy < ~/.ssh/id_ed25519.pub' and paste that into GitHub"
fi
## Getting Started

1. Install Vagrant: https://www.vagrantup.com
2. Install VirtualBox: https://www.virtualbox.org
3. Install the Vagrant VirtualBox plugin:

    ```
    vagrant plugin install vagrant-vbguest
    ```

4. Checkout the repo:

    ```
    git clone https://github.com/agentdave/minimal-rails.git
    ```

5. Build the VM:

    ```
    cd minimal-rails
    vagrant up
    ```

6. Browse: http://localhost:8080
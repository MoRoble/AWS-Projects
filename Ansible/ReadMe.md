## Automating macOS Setup with Ansible Playbook.

The idea for this project came from my experience with my old laptop encountering issues and needing to set up a new one. I realized the hassle of reinstalling all the necessary applications and decided to create a solution to simplify the process. As a DevOps engineer, automation is a key aspect of my role, and Ansible playbooks offer a robust toolset for automating software installations, dependencies, and system configurations.

Within this guide, focuses for individuals seeking to set up a new workstation without the need to search for applications across various sources, we will explore how to utilize Ansible playbooks to automate macOS setups.

To make the most of this guide, you will need the following:

- A macOS system (preferably M1-based or higher) for practicing Ansible playbooks.
- Basic knowledge of DevOps concepts and workflows.
- Familiarity with YAML syntax and a basic understanding of Ansible.


1. **Start to initiate** the process of automating the setup of macOS, begin by installing the essential developer tools using the command `sudo xcode-select --install`. This step ensures that your macOS system is equipped with the necessary components, including `git, ssh, python3`, and `make`. Once these tools are successfully installed, proceed to the following methods:
  
  - Check developer tools:
   Run the following commands to check the versions of developer tools:
   ```
   git --version
   python3 --version
   make --version
   ```
  - Get Python package manager `pip3`:
   Alternatively use the following commands to install Ansible using `pip3`:
   ```
   curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
   sudo python3 get-pip.py
   pip3 --version # optional
   
   # install Ansible
   sudo pip3 install ansible
   ## or without sudo to minimize conflicting behavior and broken permission with the system package manager
   ansible --version # optional
   ```
- Install homebrew:
   ```
   ## install homebrew on M1 Mac
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   # run these by changing your USERNAME, or copy from the screen
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
Now you can automate your macOS setup with ease using Ansible!

2. **When working with Ansible**, it's important to understand how to configure the necessary files: `hosts` and `ansible.cfg`. By default, Ansible does not generate the `ansible.cfg` file during installation; therefore, you need to create it manually if you want to customize any configurations.

- Create config file:
Create a new file named "ansible.cfg" in the desired location (Ensure that the name matches exactly as `ansible.cfg`). It's common to save it in the same directory as your Ansible playbooks, alternatively, for global configurations, save it in `/etc/ansible/ansible.cfg`, or for per-user configurations, save it as `~/.ansible.cfg`.
1. The directory specified by the `ANSIBLE_CONFIG` environment variable (if set).
2. The current working directory.
3. The user's home directory `~/.ansible.cfg`.
4. The system-wide configuration directory `/etc/ansible/ansible.cfg`.
If Ansible finds multiple `ansible.cfg` files in different locations, it will prioritize the one with the earliest match in the above order.

Open the `ansible.cfg` file and add the [defaults] section, which is mandatory. Customize this section by specifying options like inventory to set the path to your hosts file. Adjust other options according to your requirements, then save the file, here's example:
```
[defaults]
inventory = /path/to/your/hosts/file
## to disable SSH host checking for smooth automation add this line or un-comment
host_key_checking = false
```
- Create Hosts file
Next, create the hosts file, which serves as your inventory. Place it in the desired location, such as the project's root directory or your home directory as `~/.ansible/hosts`. For system-wide availability on macOS, save it in `/etc/ansible/hosts`.
Regardless of the chosen location, you can explicitly specify the path to the hosts file when running Ansible commands using the `-i` or `--inventory` option e.g., `ansible-playbook -i /path/to/your/hosts/file macos_setup.yaml`. In our project here's our hosts file:
```
[hosts]
localhost
## add configuration variables
[hosts:vars]
ansible_connection=local
ansible_python_interpreter=/usr/bin/python3
```

3. **Set up a Project Directory:** Create a new directory for your Ansible project. This directory will house your Ansible playbooks and associated files. Navigate to the project directory using the command line.

5. **Writing Ansible Playbook Tasks:**
In your project directory, create a new YAML file, e.g., `macos_setup.yml`, to define your Ansible playbook tasks. Here are some essential tasks to include:

- Installing the AWS CLI (Command Line Interface), which is a command-line tool used for managing and configuring resources on the AWS cloud.

- Installation of Development Tools: In the ansible playbook, the `homebrew` module will be used to install essential packages and tools commonly used in day-to-day DevOps activities. These include Git, ZSH, jq, wget, terraform (i.e., tf-switch), as well as the `homebrew_cask` module, which is for the management and installation of graphical tools such as Visual Studio Code, Docker Desktop, iTerm2, Sublime text, Slack, and other relevant development-related applications.

- Configuring zsh and Oh My Zsh: Customize the `.zshrc` file using the `lineinfile` module to set the desired theme, plugins, and environment variables. Integrate Oh My Zsh to enhance your shell experience.

- Get the playbook by accessing [macos_setup](https://github.com/MoRoble/AWS-Projects/blob/main/Ansible/macos_setup.yaml) YAML file and clone it into your project directory. After cloning, navigate to the playbook directory.

To run the playbook, execute the following command in your terminal: `ansible-playbook macos_setup.yml`. Ansible will execute the tasks defined in your playbook, automatically installing and configuring the specified software and settings on your macOS system.

The provided guide and sample playbooks serve as a starting point for your automation journey. Continuously expand your knowledge by exploring Ansible's extensive documentation, experimenting with more complex scenarios, and seeking opportunities to automate other aspects of your DevOps workflows.

Once you have successfully automated your macOS setup using Ansible playbooks, consider expanding your skills by exploring more advanced Ansible concepts and techniques. Some areas to focus on include:

- Templating: Utilize Ansible's templating capabilities to dynamically generate configuration files based on variables and templates.

- Roles: Organize your playbooks into reusable roles, allowing you to modularize and share common configurations across multiple projects.

- Integration with Version Control: Use Git to manage your Ansible playbooks, enabling collaboration, version control, and easy rollback.

Resources:
- Ansible Documentation: Official documentation that provides in-depth explanations of Ansible concepts, modules, and best practices.
- Homebrew: The official Homebrew [website](https://brew.sh/), offering information on how to install and use Homebrew, the macOS package manager.
- GitHub Repository: A GitHub repository with example Ansible playbooks can be found at [Ansible-MacOS](https://github.com/MoRoble/AWS-Projects/tree/main/Ansible).
- Online Communities: Engage with online communities such as Stack Overflow, Ansible Galaxy, and Ansible mailing lists to seek advice, share knowledge, and solve challenges.

Remember to customize the guide and playbooks to fit your specific needs and preferences. Share your experience by contributing to open-source Ansible projects or publishing your playbooks on GitHub. Happy automating, and welcome to the world of DevOps!

Acknowledgements:
Special thanks to Derek Morgan for his invaluable guidance on [this course](https://www.udemy.com/course/devops-in-the-cloud/). Your mentorship and expertise have been instrumental in shaping this resource for aspiring Junior DevOp engineers.

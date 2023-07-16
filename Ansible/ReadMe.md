## Automating macOS Setup with Ansible Playbook.

The idea for this project came from my experience with my old laptop encountering issues and needing to set up a new one. I realized the hassle of reinstalling all the necessary applications and decided to create a solution to simplify the process. As a DevOps engineer, automation is a key aspect of my role, and Ansible playbooks offer a robust toolset for automating software installations, dependencies, and system configurations.

Within this guide, focuses for individuals seeking to set up a new workstation without the need to search for applications across various sources, we will explore how to utilize Ansible playbooks to automate macOS setups.

To make the most of this guide, you will need the following:

1. A macOS system (preferably M1-based or higher) for practicing Ansible playbooks.
2. Basic knowledge of DevOps concepts and workflows.
3. Familiarity with YAML syntax and a basic understanding of Ansible.

Getting Started:
1. To initiate the process of automating the setup of macOS, begin by installing the essential developer tools using the command `sudo xcode-select --install`. This step ensures that your macOS system is equipped with the necessary components, including `git, ssh, python3`, and `make`. Once these tools are successfully installed, proceed to the following methods:

1. Check developer tools:
   Run the following commands to check the versions of developer tools:
   ```
   git --version
   python3 --version
   make --version
   ```
2. Get Python package manager `pip3`:
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
3. Install homebrew:
   ```
   ## install homebrew on M1 Mac
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   # run these by changing your USERNAME, or copy from the screen
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/[<<<ChangeMe>>USERNAME]/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
Now you can automate your macOS setup with ease using Ansible!

2. By default, Ansible does not automatically generate a hosts file during installation. For this project, since we're going to install applications that will work on a system-wide level, we recommend manually creating an inventory (hosts) file in the /etc/ansible/hosts directory. Additionally, a configuration file named ansible.cfg  should be placed in the same location, with a few configuration lines added to ensure smooth automation. Here is an example of how both files will appear.
```
### setup inventory file
sudo nano /etc/ansible/hosts
## add these lines
[hosts]
localhost
## add configuration variables
[hosts:vars]
ansible_connection=local
ansible_python_interpreter=/usr/bin/python3
 
# disable SSH key confirmation to run the automation smoothly
sudo vim /etc/ansible/ansible.cfg
[defaults]
# to disable SSH key host checking add this line or un-comment
host_key_checking = false
```

3. Set up a Project Directory: Create a new directory for your Ansible project. This directory will house your Ansible playbooks and associated files. Navigate to the project directory using the command line.

Writing Ansible Playbook Tasks:
In your project directory, create a new YAML file, e.g., `macos_setup.yml`, to define your Ansible playbook tasks. Here are some essential tasks to include:

- Installing the AWS CLI (Command Line Interface), which is a command-line tool used for managing and configuring resources on the AWS cloud.

- Installation of Development Tools: In the ansible playbook, the `homebrew` module will be used to install essential packages and tools commonly used in day-to-day DevOps activities. These include Git, ZSH, jq, wget, terraform (i.e., tf-switch), as well as the `homebrew_cask` module, which is for the management and installation of graphical tools such as Visual Studio Code, Docker Desktop, iTerm2, Sublime text, Slack, and other relevant development-related applications.

- Configuring zsh and Oh My Zsh: Customize the `.zshrc` file using the `lineinfile` module to set the desired theme, plugins, and environment variables. Integrate Oh My Zsh to enhance your shell experience.

- Get the playbook by accessing [the link]() and clone it into your project directory. After cloning, navigate to the playbook directory.

To run the playbook, execute the following command in your terminal: `ansible-playbook macos_setup.yml`. Ansible will execute the tasks defined in your playbook, automatically installing and configuring the specified software and settings on your macOS system.

The provided guide and sample playbooks serve as a starting point for your automation journey. Continuously expand your knowledge by exploring Ansible's extensive documentation, experimenting with more complex scenarios, and seeking opportunities to automate other aspects of your DevOps workflows.

Once you have successfully automated your macOS setup using Ansible playbooks, consider expanding your skills by exploring more advanced Ansible concepts and techniques. Some areas to focus on include:

- Templating: Utilize Ansible's templating capabilities to dynamically generate configuration files based on variables and templates.

- Roles: Organize your playbooks into reusable roles, allowing you to modularize and share common configurations across multiple projects.

- Integration with Version Control: Use Git to manage your Ansible playbooks, enabling collaboration, version control, and easy rollback.

Resources:
- Ansible Documentation: Official documentation that provides in-depth explanations of Ansible concepts, modules, and best practices.
- Homebrew: The official Homebrew website, offering information on how to install and use Homebrew, the macOS package manager.
- GitHub Repository: A GitHub repository with example Ansible playbooks can be found at [link to your GitHub repository].
- Online Communities: Engage with online communities such as Stack Overflow, Ansible Galaxy, and Ansible mailing lists to seek advice, share knowledge, and solve challenges.

Remember to customize the guide and playbooks to fit your specific needs and preferences. Share your experience by contributing to open-source Ansible projects or publishing your playbooks on GitHub. Happy automating, and welcome to the world of DevOps!

Acknowledgements:
Special thanks to Derek Morgan for his invaluable guidance on [this course](https://www.udemy.com/course/devops-in-the-cloud/). Your mentorship and expertise have been instrumental in shaping this resource for aspiring Junior DevOp engineers.
